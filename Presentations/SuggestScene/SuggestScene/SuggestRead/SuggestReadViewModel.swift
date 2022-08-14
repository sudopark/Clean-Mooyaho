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

public protocol SuggestReadViewModel: AnyObject, Sendable {

    // interactor
    func refresh()
    func selectCollection(_ itemID: String)
    func selectReadLink(_ itemID: String)
    func viewAllFavoriteRead()
    
    // presenter
    var sections: Observable<[SuggestReadSection]> { get }
    func readLinkPreview(for linkID: String) -> Observable<LinkPreview>
    var isRefreshing: Observable<Bool> { get }
}


// MARK: - SuggestReadViewModelImple

public final class SuggestReadViewModelImple: SuggestReadViewModel, @unchecked Sendable {
    
    private let readItemUsecase: ReadItemUsecase
    private let categoriesUsecase: ReadItemCategoryUsecase
    private let router: SuggestReadRouting
    private weak var listener: SuggestReadSceneListenable?
    private weak var readCollectionMainInteractor: ReadCollectionMainSceneInteractable?
    
    public init(readItemUsecase: ReadItemUsecase,
                categoriesUsecase: ReadItemCategoryUsecase,
                router: SuggestReadRouting,
                listener: SuggestReadSceneListenable?,
                readCollectionMainInteractor: ReadCollectionMainSceneInteractable?) {
        
        self.readItemUsecase = readItemUsecase
        self.categoriesUsecase = categoriesUsecase
        self.router = router
        self.listener = listener
        self.readCollectionMainInteractor = readCollectionMainInteractor
        
        self.bindRequireCategories()
        self.bindContinueReadingLinks()
        self.bindFavoriteItems()
        self.bindItemUpdateOrRemoved()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects: Sendable {
        let todoReadItems = BehaviorRelay<[ReadItem]?>(value: nil)
        let favoriteItemIDs = BehaviorRelay<[String]?>(value: nil)
        let continueReadLinks = BehaviorRelay<[ReadLink]?>(value: nil)
        let itemsMap = BehaviorRelay<[String: ReadItem]>(value: [:])
        let categoriesMap = BehaviorRelay<[String: ItemCategory]>(value: [:])
        let isRefreshing = BehaviorRelay<Bool>(value: false)
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
        self.readItemUsecase
            .continueReadingLinks()
            .do(onNext: updateMap)
            .map { $0.suffix(10).reversed() }
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
        self.readItemUsecase.sharedFavoriteItemIDs
            .map { $0.suffix(10).reversed() }
            .do(onNext: startReloadRequreItems)
            .subscribe(onNext: updateIDs)
            .disposed(by: self.disposeBag)
    }
    
    private func reloadRequireFavoriteItems(_ ids: [String]) {
        let itemsMap = self.subjects.itemsMap.value
        let notExistingIDs = ids.filter { itemsMap[$0] == nil }
        
        let loadNotExisingItems = self.readItemUsecase.loadReadItems(for: notExistingIDs)
        let updateItemsMap: ([ReadItem]) -> Void = { [weak self] items in
            self?.subjects.itemsMap.accept(withAppend: items)
        }
        loadNotExisingItems
            .subscribe(onSuccess: updateItemsMap)
            .disposed(by: self.disposeBag)
    }
    
    private func bindItemUpdateOrRemoved() {
        
        self.readItemUsecase.readItemUpdated
            .subscribe(onNext: { [weak self] event in
                self?.handleReadItemUpdated(event)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func handleReadItemUpdated(_ event: ReadItemUpdateEvent) {
        switch event {
        case let .updated(item) where (item as? ReadLink)?.isRed == true:
            self.removeReadItem(item.uid)
        case let .removed(itemID, _):
            self.removeDeletedItem(itemID)
        default: return
        }
    }
    
    private func removeReadItem(_ itemID: String) {
        let (todoItems, continueItems) = (self.subjects.todoReadItems.value, self.subjects.continueReadLinks.value)
        let newTodoItems = todoItems.map { $0.filter { $0.uid != itemID } }
        let newContinueLinks = continueItems.map { $0.filter { $0.uid != itemID } }
        (newTodoItems?.count != todoItems?.count).then {
            self.subjects.todoReadItems.accept(newTodoItems)
        }
        (newContinueLinks?.count != continueItems?.count).then {
            self.subjects.continueReadLinks.accept(newContinueLinks)
        }
    }
    
    private func removeDeletedItem(_ itemID: String) {
        self.removeReadItem(itemID)
        let favoriteIDs = self.subjects.favoriteItemIDs.value
        let newFavorite = favoriteIDs.map { $0.filter { $0 != itemID } }
        guard favoriteIDs?.count != newFavorite?.count else { return }
        self.subjects.favoriteItemIDs.accept(newFavorite)
    }
}


// MARK: - SuggestReadViewModelImple Interactor

extension SuggestReadViewModelImple {
 
    public func refresh() {
        self.reloadTodoReadItems()
        self.reloadFavoriteItemIDs()
    }
    
    private func reloadTodoReadItems() {
        guard self.subjects.isRefreshing.value == false else { return }
        
        let updateItemsMap: ([ReadItem]) -> Void = { [weak self] items in
            self?.subjects.isRefreshing.accept(false)
            self?.subjects.itemsMap.accept(withAppend: items)
        }
        let updateTodoItems: ([ReadItem]) -> Void = { [weak self] items in
            self?.subjects.isRefreshing.accept(false)
            self?.subjects.todoReadItems.accept(items)
        }
        self.subjects.isRefreshing.accept(true)
        self.readItemUsecase
            .suggestNextReadItem(size: 10)
            .catchAndReturn([])
            .do(onNext: updateItemsMap)
            .subscribe(onSuccess: updateTodoItems)
            .disposed(by: self.disposeBag)
    }
    
    private func reloadFavoriteItemIDs() {
        self.readItemUsecase.refreshSharedFavoriteIDs()
    }
}

// MARK: - SuggestReadViewModelImple Interactor + move detail

extension SuggestReadViewModelImple {
    
    public func selectCollection(_ itemID: String) {
        self.listener?.finishSuggesting { [weak self] in
            self?.readCollectionMainInteractor?.jumpToCollection(itemID)
        }
    }
    
    public func selectReadLink(_ itemID: String) {
        self.router.showLinkDetail(itemID)
    }
    
    public func innerWebView(reqeustJumpTo collectionID: String?) {
        self.listener?.finishSuggesting { [weak self] in
            self?.readCollectionMainInteractor?.jumpToCollection(collectionID)
        }
    }
}

// MARK: - SuggestReadViewModelImple Interactor + view all

extension SuggestReadViewModelImple {
    
    public func viewAllFavoriteRead() {
        self.router.showAllFavoriteItemList()
    }
    
    public func favoriteItemsScene(didRequestJump collectionID: String?) {
        self.listener?.finishSuggesting { [weak self] in
            self?.readCollectionMainInteractor?.jumpToCollection(collectionID)
        }
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
            
            let sections: [SuggestReadSection?] = [
                todoReadCells.asSection(type: .todoRead, emptyThenNil: true),
                favoriteCells.asSection(type: .favotire),
                continueReadingCells.asSection(type: .continueRead)
            ]
            return sections.compactMap { $0 }
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
        return self.readItemUsecase.loadLinkPreview(item.link)
    }
    
    private var favoriteItems: Observable<[ReadItem]> {
        
        let extractItems: ( [String], [String: ReadItem]) -> [ReadItem] = { ids, itemsMap in
            return ids.compactMap { itemsMap[$0] }
        }
        
        return Observable.combineLatest(
            self.subjects.favoriteItemIDs.compactMap { $0 },
            self.subjects.itemsMap,
            resultSelector: extractItems
        )
    }
    
    private var continueReadLinks: Observable<[ReadItem]> {
        return self.subjects.continueReadLinks.compactMap { $0 }
    }
    
    public var isRefreshing: Observable<Bool> {
        return self.subjects.isRefreshing
            .distinctUntilChanged()
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
    
    func asSection(type: SuggestReadSection.SuggestType, emptyThenNil: Bool = false) -> SuggestReadSection? {
        switch self.isNotEmpty {
        case true:
            return .init(type: type, cellViewModels: self)
        case false where emptyThenNil:
            return nil
        case false:
            return .init(type: type, cellViewModels: [SuggestEmptyCellViewModel(type: type)])
        }
    }
}

private extension BehaviorRelay where Element == [String: ReadItem] {
    
    func accept(withAppend newItems: [ReadItem]) {
        let newMap = newItems.reduce(into: [String: ReadItem]()) { $0[$1.uid] = $1 }
        let updatedMap = self.value.merging(newMap, uniquingKeysWith: { $1 })
        self.accept(updatedMap)
    }
}

