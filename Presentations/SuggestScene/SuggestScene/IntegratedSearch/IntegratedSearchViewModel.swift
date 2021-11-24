//
//  IntegratedSearchViewModel.swift
//  SuggestScene
//
//  Created sudo.park on 2021/11/23.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay
import Prelude
import Optics

import Domain
import CommonPresenting


// MARK: - cellViewModels + Section

public protocol SearchIndexCellViewMdoel {
    var identifier: String { get }
    var displayName: String { get }
    var description: String? { get }
    
    var presentingKey: Int { get }
}

public protocol SearchIndexCellViewMdoelFactory {
    
    associatedtype IndexType
    
    init(index: IndexType)
}

public protocol SearchIndexCellViewMdoelType: SearchIndexCellViewMdoel, SearchIndexCellViewMdoelFactory { }

public struct SearchReadItemCellViewModel: SearchIndexCellViewMdoelType {
    
    public typealias IndexType = SearchReadItemIndex
    
    public let identifier: String
    public let isCollection: Bool
    public let displayName: String
    
    public var categories: [ItemCategory] = []
    public let description: String?
    
    public init(index: SearchReadItemIndex) {
        self.identifier = index.itemID
        self.isCollection = index.isCollection
        self.displayName = index.displayName
        self.description = index.description
    }
    
    public var presentingKey: Int {
        var hasher = Hasher()
        hasher.combine(self.identifier)
        hasher.combine(self.isCollection)
        hasher.combine(self.categories.map { $0.presentingKey })
        hasher.combine(self.description)
        return hasher.finalize()
    }
}

private extension ItemCategory {
    
    var presentingKey: Int {
        var hasher = Hasher()
        hasher.combine(self.uid)
        hasher.combine(self.name)
        hasher.combine(self.colorCode)
        return hasher.finalize()
    }
}

public struct SearchResultSection: Equatable {
    
    public let title: String
    public let cellViewModels: [SearchIndexCellViewMdoel]
    
    public static func == (_ lhs: Self, _ rhs: Self) -> Bool {
        return lhs.title == rhs.title
            && lhs.cellViewModels.map { $0.presentingKey } == rhs.cellViewModels.map { $0.presentingKey }
    }
}


// MARK: - IntegratedSearchViewModel

public protocol IntegratedSearchViewModel: AnyObject {

    // interactor
    func setupSubScene()
    func requestSuggest(with text: String)
    func requestSearchItems(with text: String)
    func showSearchResultDetail(_ identifier: String)
    
    // presenter
    var showSuggestScene: Observable<Bool> { get }
    var searchResultSections: Observable<[SearchResultSection]> { get }
    var resultIsEmpty: Observable<Bool> { get }
}


// MARK: - IntegratedSearchViewModelImple

public final class IntegratedSearchViewModelImple: IntegratedSearchViewModel {
    
    private let searchUsecase: IntegratedSearchUsecase
    private let categoryUsecase: ReadItemCategoryUsecase
    private let router: IntegratedSearchRouting
    private weak var listener: IntegratedSearchSceneListenable?
    
    public init(searchUsecase: IntegratedSearchUsecase,
                categoryUsecase: ReadItemCategoryUsecase,
                router: IntegratedSearchRouting,
                listener: IntegratedSearchSceneListenable?) {
        
        self.searchUsecase = searchUsecase
        self.categoryUsecase = categoryUsecase
        self.router = router
        self.listener = listener
        
        self.bindCategories()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
        let isSuggestSceneShowing = BehaviorRelay<Bool>(value: false)
        let searchedIndexes = BehaviorRelay<[SearchReadItemIndex]?>(value: nil)
        let categoriesMap = BehaviorRelay<[String: ItemCategory]>(value: [:])
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    private var searchingJob: Disposable?
    
    private weak var suggestInteractor: SuggestQuerySceneInteractable?
    
    private func bindCategories() {
        
        let requeireCategoryIDs = self.subjects.searchedIndexes
            .compactMap { $0 }
            .map { $0.flatMap { $0.categoryIDs } }
            .map { Array(Set($0)) }
        let loadCategories: ([String]) -> Observable<[ItemCategory]> = { [weak self] ids in
            guard let self = self else { return .empty() }
            return self.categoryUsecase.categories(for: ids)
        }
        requeireCategoryIDs
            .flatMapLatest(loadCategories)
            .subscribe(onNext: { [weak self] categories in
                let dict = categories.reduce(into: [String: ItemCategory]()) { $0[$1.uid] = $1 }
                self?.subjects.categoriesMap.accept(dict)
            })
            .disposed(by: self.disposeBag)
    }
}


// MARK: - IntegratedSearchViewModelImple Interactor

extension IntegratedSearchViewModelImple {
    
    public func setupSubScene() {
        self.suggestInteractor = self.router.setupSuggestScene()
        self.requestSuggest(with: "")
    }
    
    public func requestSuggest(with text: String) {
        guard let interactor = self.suggestInteractor else { return }
        self.searchingJob?.dispose()
        interactor.suggest(with: text)
        self.subjects.isSuggestSceneShowing.accept(true)
    }
    
    public func requestSearchItems(with text: String) {
        
        guard text.isNotEmpty else { return }
        
        let handleResult: ([SearchReadItemIndex]) -> Void = { [weak self] results in
            self?.subjects.isSuggestSceneShowing.accept(false)
            self?.listener?.integratedSearch(didUpdateSearching: false)
            self?.subjects.searchedIndexes.accept(results)
        }
        
        let handleError: (Error) -> Void = { [weak self] error in
            self?.listener?.integratedSearch(didUpdateSearching: false)
            self?.router.alertError(error)
        }
        
        self.searchingJob?.dispose()
        self.listener?.integratedSearch(didUpdateSearching: true)
        self.searchingJob = self.searchUsecase.search(query: text)
            .subscribe(onSuccess: handleResult, onError: handleError)
    }
    
    public func showSearchResultDetail(_ identifier: String) {
        guard let indexes = self.subjects.searchedIndexes.value,
              let index = indexes.first(where: { $0.itemID == identifier })
        else {
            return
        }
        self.router.showReadItemSnapshot(index)
    }
}

// MARK: - IntegratedSearchViewModelImple Interactor + select suggest

extension IntegratedSearchViewModelImple {
    
    public func suggestQuery(didSelect searchQuery: String) {
        self.requestSearchItems(with: searchQuery)
    }
}


// MARK: - IntegratedSearchViewModelImple Presenter

extension IntegratedSearchViewModelImple {
    
    public var showSuggestScene: Observable<Bool> {
        return self.subjects
            .isSuggestSceneShowing
            .distinctUntilChanged()
    }
    
    public var searchResultSections: Observable<[SearchResultSection]> {
        
        let asSections: ([SearchReadItemIndex], [String: ItemCategory]) -> [SearchResultSection]
        asSections = { indexes, categoryMap in
            let collections = indexes.filter { $0.isCollection }
                .asCellViewModel(with: categoryMap)
                .asSectionIfNotEmpty(title: "Collections".localized)
            let links = indexes.filter { $0.isCollection == false }
                .asCellViewModel(with: categoryMap)
                .asSectionIfNotEmpty(title: "Links".localized)
            let sections: [SearchResultSection?] = [collections, links]
            return sections.compactMap { $0 }
        }
        
        return Observable
            .combineLatest(self.subjects.searchedIndexes.compactMap { $0 },
                           self.subjects.categoriesMap,
                           resultSelector: asSections)
            .distinctUntilChanged()
    }
    
    public var resultIsEmpty: Observable<Bool> {
        return self.subjects.searchedIndexes
            .compactMap { $0?.isEmpty }
            .distinctUntilChanged()
    }
}


private extension Array where Element == SearchReadItemIndex {
    
    func asCellViewModel(with categoryMap: [String: ItemCategory]) -> [SearchReadItemCellViewModel] {
        return self.map { index in
            return SearchReadItemCellViewModel(index: index)
                |> \.categories .~ index.categoryIDs.compactMap { categoryMap[$0] }
        }
    }
}

private extension Array where Element == SearchReadItemCellViewModel {
    
    func asSectionIfNotEmpty(title: String) -> SearchResultSection? {
        guard self.isNotEmpty else { return nil }
        return .init(title: title, cellViewModels: self)
    }
}
