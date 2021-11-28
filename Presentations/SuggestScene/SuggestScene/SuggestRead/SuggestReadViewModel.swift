//
//  SuggestReadViewModel.swift
//  SuggestScene
//
//  Created sudo.park on 2021/11/27.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay
import Prelude
import Optics

import Domain
import CommonPresenting


public struct SuggestReadSection: Equatable {
    
    public enum SuggestType: String {
        case todoRead
        case favotire
        case continueRead
    }
    
    let type: SuggestType
    let cellViewModels: [ReadItemCellViewModel]
    
    public static func == (_ lhs: Self, _ rhs: Self) -> Bool {
        return lhs.type == rhs.type
            && lhs.cellViewModels.map { $0.presetingID } == rhs.cellViewModels.map { $0.presetingID }
    }
}

public struct SuggestEmptyCellViewModel: ReadItemCellViewModel {
    
    let sectionType: SuggestReadSection.SuggestType
    init(type: SuggestReadSection.SuggestType) { self.sectionType = type }
    
    public var uid: String { self.sectionType.rawValue }
    
    public var presetingID: Int {
        var hasher = Hasher()
        hasher.combine(self.uid)
        return hasher.finalize()
    }
}


// MARK: - SuggestReadViewModel

public protocol SuggestReadViewModel: AnyObject {

    // interactor
    func refresh()
    func selectCollection(_ itemID: String)
    func selectReadLink(_ itemID: String)
    func viewAllTodoRead()
    func viewAllFavoriteRead()
    func viewAllLatestRead()
    
    // presenter
    var sections: Observable<[SuggestReadSection]> { get }
    func readLinkPreview(for linkID: String) -> Observable<LinkPreview>
}


// MARK: - SuggestReadViewModelImple

public final class SuggestReadViewModelImple: SuggestReadViewModel {
    
    private let readItemLoadUsecase: ReadItemLoadUsecase
    private let favoriteItemUsecase: FavoriteReadItemUsecas
    private let categoriesUsecase: ReadItemCategoryUsecase
    private let router: SuggestReadRouting
    private weak var listener: SuggestReadSceneListenable?
    private weak var readCollectionMainInteractor: ReadCollectionMainSceneInteractable?
    
    public init(readItemLoadUsecase: ReadItemLoadUsecase,
                favoriteItemUsecase: FavoriteReadItemUsecas,
                categoriesUsecase: ReadItemCategoryUsecase,
                router: SuggestReadRouting,
                listener: SuggestReadSceneListenable?,
                readCollectionMainInteractor: ReadCollectionMainSceneInteractable?) {
        
        self.readItemLoadUsecase = readItemLoadUsecase
        self.favoriteItemUsecase = favoriteItemUsecase
        self.categoriesUsecase = categoriesUsecase
        self.router = router
        self.listener = listener
        self.readCollectionMainInteractor = readCollectionMainInteractor
        
        self.bindRequireCategories()
        self.bindContinueReadingLinks()
        self.bindFavoriteItems()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
        let todoReadItems = BehaviorRelay<[ReadItem]?>(value: nil)
        let favoriteItemIDs = BehaviorRelay<[String]?>(value: nil)
        let continueReadLinks = BehaviorRelay<[ReadLink]?>(value: nil)
        let itemsMap = BehaviorRelay<[String: ReadItem]>(value: [:])
        let categoriesMap = BehaviorRelay<[String: ItemCategory]>(value: [:])
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private func bindRequireCategories() {
        
        let requireCategoryIDs = self.subjects.itemsMap
            .map { $0.values }
            .map { $0.flatMap { $0.categoryIDs } }
        
        let updateSubject: ([String: ItemCategory]) -> Void = { [weak self] cateMap in
            self?.subjects.categoriesMap.accept(cateMap)
        }
        self.categoriesUsecase
            .requireCategoryMap(from: requireCategoryIDs)
            .subscribe(onNext: updateSubject)
            .disposed(by: self.disposeBag)
    }
    
    private func bindContinueReadingLinks() {
        let updateMap: ([ReadLink]) -> Void = { [weak self] links in
            self?.subjects.itemsMap.accept(withAppend: links)
        }
        let updateContinueReadLinks: ([ReadLink]) -> Void = { [weak self] links in
            self?.subjects.continueReadLinks.accept(links)
        }
        self.readItemLoadUsecase
            .continueReadingLinks()
            .do(onNext: updateMap)
            .map { $0.suffix(5) }
            .subscribe(onNext: updateContinueReadLinks)
            .disposed(by: self.disposeBag)
    }
    
    private func bindFavoriteItems() {
        let startReloadRequreItems: ([String]) -> Void = { [weak self] ids in
            self?.reloadRequireFavoriteItems(ids)
        }
        let updateIDs: ([String]) -> Void = { [weak self] ids in
            self?.subjects.favoriteItemIDs.accept(ids)
        }
        self.favoriteItemUsecase.sharedFavoriteItemIDs
            .map { $0.suffix(5) }
            .do(onNext: startReloadRequreItems)
            .subscribe(onNext: updateIDs)
            .disposed(by: self.disposeBag)
    }
    
    private func reloadRequireFavoriteItems(_ ids: [String]) {
        let itemsMap = self.subjects.itemsMap.value
        let notExistingIDs = ids.filter { itemsMap[$0] == nil }
        
        let loadNotExisingItems = self.readItemLoadUsecase.loadReadItems(for: notExistingIDs)
        let updateItemsMap: ([ReadItem]) -> Void = { [weak self] items in
            self?.subjects.itemsMap.accept(withAppend: items)
        }
        loadNotExisingItems
            .subscribe(onSuccess: updateItemsMap)
            .disposed(by: self.disposeBag)
    }
}


// MARK: - SuggestReadViewModelImple Interactor

extension SuggestReadViewModelImple {
 
    public func refresh() {
        self.reloadTodoReadItems()
        self.reloadFavoriteItemIDs()
    }
    
    private func reloadTodoReadItems() {
        let updateItemsMap: ([ReadItem]) -> Void = { [weak self] items in
            self?.subjects.itemsMap.accept(withAppend: items)
        }
        let updateTodoItems: ([ReadItem]) -> Void = { [weak self] items in
            self?.subjects.todoReadItems.accept(items)
        }
        self.readItemLoadUsecase
            .suggestNextReadItem(size: 5)
            .catchAndReturn([])
            .do(onNext: updateItemsMap)
            .subscribe(onSuccess: updateTodoItems)
            .disposed(by: self.disposeBag)
    }
    
    private func reloadFavoriteItemIDs() {
        self.favoriteItemUsecase.refreshSharedFavoriteIDs()
    }
}

// MARK: - SuggestReadViewModelImple Interactor + move detail

extension SuggestReadViewModelImple {
    
    public func selectCollection(_ itemID: String) {
        self.readCollectionMainInteractor?.jumpToCollection(itemID)
    }
    
    public func selectReadLink(_ itemID: String) {
        self.router.showLinkDetail(itemID)
    }
}

// MARK: - SuggestReadViewModelImple Interactor + view all

extension SuggestReadViewModelImple {
    
    public func viewAllTodoRead() {
        self.router.showAllTodoReadItems()
    }
    
    public func viewAllFavoriteRead() {
        self.router.showAllFavoriteItemList()
    }
    
    public func viewAllLatestRead() {
        self.router.showAllLatestReadItems()
    }
}


// MARK: - SuggestReadViewModelImple Presenter

extension SuggestReadViewModelImple {
    
    public var sections: Observable<[SuggestReadSection]> {
        
        let asSections: (
            [ReadItem], [ReadItem], [ReadItem], [String: ItemCategory]
        ) -> [SuggestReadSection]
        asSections = { todoItems, favoriteItems, continueReadings, categoryMaps in
            let todoReadCells = todoItems.asCellViewModels(with: categoryMaps)
            let favoriteCells = favoriteItems.asCellViewModels(with: categoryMaps)
            let continueReadingCells = continueReadings.asCellViewModels(with: categoryMaps)
            
            return [
                todoReadCells.asSection(type: .todoRead),
                favoriteCells.asSection(type: .favotire),
                continueReadingCells.asSection(type: .continueRead)
            ]
        }
        
        return Observable.combineLatest(
            self.subjects.todoReadItems.compactMap { $0 },
            self.favoriteItems,
            self.subjects.continueReadLinks.compactMap { $0 },
            self.subjects.categoriesMap,
            resultSelector: asSections
        )
        .distinctUntilChanged()
    }
    
    public func readLinkPreview(for linkID: String) -> Observable<LinkPreview> {
        guard let item = self.subjects.itemsMap.value[linkID] as? ReadLink else { return .empty() }
        return self.readItemLoadUsecase.loadLinkPreview(item.link)
    }
    
    private var favoriteItems: Observable<[ReadItem]> {
        let extractItems: ([String], [String: ReadItem]) -> [ReadItem] = { ids, itemsMap in
            return ids.compactMap { itemsMap[$0] }
        }
        return self.subjects.favoriteItemIDs
            .compactMap { $0 }
            .withLatestFrom(self.subjects.itemsMap, resultSelector: extractItems)
    }
    
    private var continueReadLinks: Observable<[ReadItem]> {
        return self.subjects.continueReadLinks.compactMap { $0 }
    }
}

private extension Array where Element == ReadItem {
    
    func asCellViewModels(with categoryMap: [String: ItemCategory]) -> [ReadItemCellViewModel] {
        
        let transform: (ReadItem) -> ReadItemCellViewModel? = { item in
            switch item {
            case let collection as ReadCollection:
                return ReadCollectionCellViewModel(item: collection)
                    |> \.categories .~ (collection.categoryIDs.compactMap { categoryMap[$0] })
                
            case let link as ReadLink:
                return ReadLinkCellViewModel(item: link)
                    |> \.categories .~ (link.categoryIDs.compactMap { categoryMap[$0] })
            default: return nil
            }
        }
        
        return self.compactMap(transform)
    }
}

private extension Array where Element == ReadItemCellViewModel {
    
    func asSection(type: SuggestReadSection.SuggestType) -> SuggestReadSection {
        guard self.isNotEmpty else {
            return .init(type: type, cellViewModels: [SuggestEmptyCellViewModel(type: type)])
        }
        return .init(type: type, cellViewModels: self)
    }
}

private extension BehaviorRelay where Element == [String: ReadItem] {
    
    func accept(withAppend newItems: [ReadItem]) {
        let newMap = newItems.reduce(into: [String: ReadItem]()) { $0[$1.uid] = $1 }
        let updatedMap = self.value.merging(newMap, uniquingKeysWith: { $1 })
        self.accept(updatedMap)
    }
}

