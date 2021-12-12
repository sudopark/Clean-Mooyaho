//
//  ReadCollectionViewModel.swift
//  ReadItemScene
//
//  Created sudo.park on 2021/09/19.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay
import Prelude
import Optics

import Domain
import CommonPresenting


public enum ReadCollectionItemSwipeContextAction: Equatable {
    case edit
    case delete
    case remind(isOn: Bool)
    case markAsRead(isRed: Bool)
    case favorite(isFavorite: Bool)
}


// MARK: - ReadCollectionViewModel

public protocol ReadCollectionItemsViewModel: AnyObject {
    
    var currentCollectionID: String? { get }

    // interactor
    func reloadCollectionItems()
    func requestPrepareParentIfNeed()
    func requestChangeOrder()
    func openItem(_ itemID: String)
    func addNewCollectionItem()
    func addNewReadLinkItem()
    func handleContextAction(for item: ReadItemCellViewModel,
                             action: ReadCollectionItemSwipeContextAction)
    func editCollection()
    func viewDidAppear()
    
    
    // presenter
    var collectionTitle: Observable<String> { get }
    var currentSortOrder: Observable<ReadCollectionItemSortOrder> { get }
    var sections: Observable<[ReadCollectionItemSection]> { get }
    func readLinkPreview(for linkID: String) -> Observable<LinkPreview>
    var isEditable: Observable<Bool> { get }
    func contextAction(for item: ReadItemCellViewModel,
                       isLeading: Bool) -> [ReadCollectionItemSwipeContextAction]?
}


// MARK: - ReadCollectionViewModelImple

public final class ReadCollectionViewItemsModelImple: ReadCollectionItemsViewModel {
    
    public let currentCollectionID: String?
    private let readItemUsecase: ReadItemUsecase
    private let favoriteUsecase: FavoriteReadItemUsecas
    private let categoryUsecase: ReadItemCategoryUsecase
    private let remindUsecase: ReadRemindUsecase
    private let router: ReadCollectionRouting
    private weak var navigationListener: ReadCollectionNavigateListenable?
    private weak var inverseNavigationCoordinating: CollectionInverseNavigationCoordinating?
    
    public init(collectionID: String?,
                readItemUsecase: ReadItemUsecase,
                favoriteUsecase: FavoriteReadItemUsecas,
                categoryUsecase: ReadItemCategoryUsecase,
                remindUsecase: ReadRemindUsecase,
                router: ReadCollectionRouting,
                navigationListener: ReadCollectionNavigateListenable?,
                inverseNavigationCoordinating: CollectionInverseNavigationCoordinating? = nil) {
        self.currentCollectionID = collectionID
        self.readItemUsecase = readItemUsecase
        self.favoriteUsecase = favoriteUsecase
        self.categoryUsecase = categoryUsecase
        self.remindUsecase = remindUsecase
        self.router = router
        self.navigationListener = navigationListener
        self.inverseNavigationCoordinating = inverseNavigationCoordinating
        
        self.internalBinding()
    }
    
    private var substituteCollectionID: String {
        return self.currentCollectionID ?? ReadCollection.rootID
    }
    
    private var isRootCollection: Bool {
        return self.currentCollectionID == nil
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
        let currentCollection = BehaviorSubject<ReadCollection?>(value: nil)
        let sortOrder = BehaviorRelay<ReadCollectionItemSortOrder?>(value: nil)
        let collections = BehaviorRelay<[ReadCollection]?>(value: nil)
        let links = BehaviorRelay<[ReadLink]?>(value: nil)
        let categoryMap = BehaviorSubject<[String: ItemCategory]>(value: [:])
        let favoriteIDSet = BehaviorRelay<Set<String>>(value: [])
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private func internalBinding() {
        self.bindCurrentSortOrder()
        self.loadCurrentCollectionInfoIfNeed()
        self.bindRequireCategories()
        self.bindSubItemUpdated()
        self.bindFavoriteItems()
    }
    
    private func bindCurrentSortOrder() {
        let setupLatestSortOrder: (ReadCollectionItemSortOrder) -> Void = { [weak self] order in
            self?.subjects.sortOrder.accept(order)
        }
        self.readItemUsecase
            .sortOrder
            .subscribe(onNext: setupLatestSortOrder)
            .disposed(by: self.disposeBag)
    }
    
    private func loadCurrentCollectionInfoIfNeed() {
        guard self.substituteCollectionID != ReadCollection.rootID else { return }
        
        let updateCurrentCollection: (ReadCollection) -> Void = { [weak self] collection in
            self?.subjects.currentCollection.onNext(collection)
        }
        self.readItemUsecase
            .loadCollectionInfo(self.substituteCollectionID)
            .subscribe(onNext: updateCurrentCollection)
            .disposed(by: self.disposeBag)
    }
    
    private func bindRequireCategories() {
        
        let itemSources: [Observable<[ItemCategoryPresentable]>] = [
            self.subjects.collections.compactMap { $0 },
            self.subjects.links.compactMap { $0 },
            self.subjects.currentCollection.compactMap { $0 }.map { [$0] }
        ]
        
        let updateSubject: ([String: ItemCategory]) -> Void = { [weak self] cateMap in
            self?.subjects.categoryMap.onNext(cateMap)
        }
        
        self.categoryUsecase
            .requireCategoryMap(from: itemSources)
            .subscribe(onNext: updateSubject)
            .disposed(by: self.disposeBag)
    }
    
    private func bindFavoriteItems() {
        
        let updateSubject: ([String]) -> Void = { [weak self] ids in
            let idsSet = Set(ids)
            self?.subjects.favoriteIDSet.accept(idsSet)
        }
        self.favoriteUsecase.sharedFavoriteItemIDs
            .subscribe(onNext: updateSubject)
            .disposed(by: self.disposeBag)
    }
    
    private func bindSubItemUpdated() {
        
        let handleUpdate: (ReadItemUpdateEvent) -> Void = { [weak self] event in
            guard let self = self else { return }
            switch event {
            case let .updated(newItem) where newItem.uid == self.currentCollectionID :
                self.updateCurrentCollection(newItem)
                
            case let .updated(newItem) where newItem.parentID == self.currentCollectionID:
                self.updateSubItem(newItem)
                
            case let .updated(newItem) where newItem.parentID != self.currentCollectionID:
                self.checkSubLinkItemParentChanged(newItem)
                
            case let .removed(itemID, parent) where parent == self.currentCollectionID:
                self.removeItemFromTheListIfNeed(itemID)
                
            default: break
            }
        }
        self.readItemUsecase.readItemUpdated
            .subscribe(onNext: handleUpdate)
            .disposed(by: self.disposeBag)
    }
    
    private func updateCurrentCollection(_ newItem: ReadItem) {
        guard let collection = newItem as? ReadCollection, self.isRootCollection == false else { return }
        self.subjects.currentCollection.onNext(collection)
    }
    
    private func updateSubItem(_ newItem: ReadItem) {
        switch newItem {
        case let collection as ReadCollection:
            guard let collections = self.subjects.collections.value else { return }
            let index = collections.firstIndex(where: { $0.uid == newItem.uid })
            let newCollection = index.map { collections |> ix($0) .~ collection } ?? collections + [collection]
            self.subjects.collections.accept(newCollection)
            
        case let link as ReadLink:
            guard let links = self.subjects.links.value else { return }
            let index = links.firstIndex(where: { $0.uid == link.uid })
            let newLinks = index.map { links |> ix($0) .~ link } ?? links + [link]
            self.subjects.links.accept(newLinks)
            
        default: break
        }
    }
    
    private func checkSubLinkItemParentChanged(_ item: ReadItem) {
        guard let link = item as? ReadLink,
              let links = self.subjects.links.value, links.isNotEmpty else { return }
        let newLinks = links.filter { $0.uid != link.uid }
        guard newLinks.count != links.count else { return }
        self.subjects.links.accept(newLinks)
    }
    
    private func removeItemFromTheListIfNeed(_ itemID: String) {
        
        func removeFromCollectionsIfNeed() -> Void? {
            let collections = self.subjects.collections.value ?? []
            let newCollections = collections.filter { $0.uid != itemID }
            guard collections.count != newCollections.count else { return nil }
            return self.subjects.collections.accept(newCollections)
        }
        
        func removeFromLinksIfNeed() {
            let links = self.subjects.links.value ?? []
            let newLinks = links.filter { $0.uid != itemID }
            guard newLinks.count != links.count else { return }
            self.subjects.links.accept(newLinks)
        }
        
        return removeFromCollectionsIfNeed() ?? removeFromLinksIfNeed()
    }
    
    public func viewDidAppear() {
        let subCollectionID = self.currentCollectionID
        self.navigationListener?.readCollection(didShowMy: subCollectionID)
    }
}


// MARK: - ReadCollectionViewModelImple Interactor

extension ReadCollectionViewItemsModelImple {
    
    public func reloadCollectionItems() {
        
        let updateList: ([ReadItem]) -> Void = { [weak self] itemes in
            let collections = itemes.compactMap{ $0 as? ReadCollection }
            let links = itemes.compactMap{ $0 as? ReadLink }
            self?.subjects.collections.accept(collections)
            self?.subjects.links.accept(links)
        }
        let handleError: (Error) -> Void = { [weak self] error in
            self?.router.alertError(error)
        }
        let loadItems = self.currentCollectionID
            .map { self.readItemUsecase.loadCollectionItems($0) } ?? self.readItemUsecase.loadMyItems()
            
        loadItems
            .subscribe(onNext: updateList, onError: handleError)
            .disposed(by: self.disposeBag)
    }
    
    public func requestPrepareParentIfNeed() {
        guard self.isRootCollection == false else { return }
        let waitUntilCurrentCollectionLoadedFirstTime = self.subjects.currentCollection
            .compactMap { $0 }
            .take(1)
        let requestPrepareOrNot: (ReadCollection) -> Void = { [weak self] collection in
            guard let parentID = collection.parentID else { return }
            self?.inverseNavigationCoordinating?.inverseNavigating(prepareParent: parentID)
        }
        waitUntilCurrentCollectionLoadedFirstTime
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: requestPrepareOrNot)
            .disposed(by: self.disposeBag)
    }
    
    public func requestChangeOrder() {
        guard let currentOrder = self.subjects.sortOrder.value else { return }
        
        let newSortSelected: (ReadCollectionItemSortOrder?) -> Void = { [weak self] newOrder in
            self?.subjects.sortOrder.accept(newOrder)
        }
        
        self.router.showItemSortOrderOptions(currentOrder, selectedHandler: newSortSelected)
    }
    
    public func openItem(_ itemID: String) {
        let totalItems: [ReadItem] = (self.subjects.collections.value ?? []) + (self.subjects.links.value ?? [])
        guard let item = totalItems.first(where: { $0.uid == itemID }) else { return }
        switch item {
        case let collectionItem as ReadCollection:
            self.router.moveToSubCollection(collectionID: collectionItem.uid)
            
        case let linkItem as ReadLink:
            self.router.showLinkDetail(linkItem)
            
        default: break
        }
    }

    
    public func handleContextAction(for item: ReadItemCellViewModel,
                                    action: ReadCollectionItemSwipeContextAction) {
        switch item {
        case let colleciton as ReadCollectionCellViewModel where action == .edit:
            self.requestEditCollection(colleciton)
            
        case let link as ReadLinkCellViewModel where action == .edit:
            self.requestEditReadLink(link)
                
        case _ where action == .remind(isOn: true):
            self.askConfirmCancelRemind(for: item.uid)
            
        case _ where action == .remind(isOn: false):
            self.requestSetupRemind(for: item.uid)
            
        case let link as ReadLinkCellViewModel where action == .markAsRead(isRed: true):
            self.toggleReadLinkIsRedMark(link.uid, isRedNow: true)
            
        case let link as ReadLinkCellViewModel where action == .markAsRead(isRed: false):
            self.toggleReadLinkIsRedMark(link.uid, isRedNow: false)
            
        case _ where action == .delete:
            guard let readItem = self.item(for: item.uid) else { return }
            self.requestRemoveReadItem(readItem)
            
        case _ where action == .favorite(isFavorite: true):
            self.toggleIsFavorite(item.uid, isFavorite: true)
            
        case _ where action == .favorite(isFavorite: false):
            self.toggleIsFavorite(item.uid, isFavorite: false)
            
        default: break
        }
    }
    
    public func editCollection() {
        
        let edit = ActionSheetForm.Action(text: "Edit collection".localized) { [weak self] in
            guard let collection = try? self?.subjects.currentCollection.value() else { return }
            self?.router.routeToEditCollection(collection)
        }
        let changeOrder = ActionSheetForm.Action(text: "Change order".localized) { [weak self] in
            guard let self = self else { return }
            self.router.roueToEditCustomOrder(for: self.currentCollectionID)
        }
        let delete = ActionSheetForm.Action(text: "Delete".localized) { [weak self] in
            guard let collection = try? self?.subjects.currentCollection.value() else { return }
            self?.requestRemoveReadItem(collection)
        }
        let cancel = ActionSheetForm.Action(text: "Cancel".localized, isCancel: true)
        
        let actions = self.isRootCollection ? [changeOrder, cancel] : [edit, changeOrder, delete, cancel]
        let form = ActionSheetForm(title: "Select action")
            |> \.actions .~ actions
        self.router.alertActionSheet(form)
    }
    
    private func toggleReadLinkIsRedMark(_ itemID: String, isRedNow: Bool) {
        guard let item = self.item(for: itemID) as? ReadLink else { return }
        let isToRed = isRedNow.invert()
        self.readItemUsecase.updateLinkItemMark(item, asRead: isToRed)
            .subscribe(onError: self.handleError())
            .disposed(by: self.disposeBag)
    }
    
    private func toggleIsFavorite(_ itemID: String, isFavorite: Bool) {
        let toIsOn = isFavorite.invert()
        self.readItemUsecase
            .toggleFavorite(itemID: itemID, toOn: toIsOn)
            .subscribe(onError: self.handleError())
            .disposed(by: self.disposeBag)
    }
    
    private func handleError() -> (Error) -> Void {
        return { [weak self] error in
            self?.router.alertError(error)
        }
    }
}


// MARK: - ReadCollectionViewModelImple Interactor + edit collection

extension ReadCollectionViewItemsModelImple {
    
    public func addNewCollectionItem() {
        
        let collectionID = self.currentCollectionID
        
        self.router.routeToMakeNewCollectionScene(at: collectionID)
    }
    
    private func requestEditCollection(_ item: ReadCollectionCellViewModel) {
        guard let collection = self.subjects.collections.value?.first(where: { $0.uid == item.uid }) else { return }
        self.router.routeToEditCollection(collection)
    }
    
    public func editReadCollection(didChange collection: ReadCollection) { }
}


// MARK: - ReadCollectionViewModelImple Interactor + edit read link

extension ReadCollectionViewItemsModelImple {
    
    public func addNewReadLinkItem() {
        
        let collectionID = self.currentCollectionID
        self.router.routeToAddNewLink(at: collectionID, startWith: nil)
    }
    
    public func addNewReadLinkItem(using url: String) {
        let collectionID = self.currentCollectionID
        self.router.routeToAddNewLink(at: collectionID, startWith: url)
    }
    
    private func requestEditReadLink(_ item: ReadLinkCellViewModel) {
        guard let link = self.subjects.links.value?.first(where: { $0.uid == item.uid }) else { return }
        self.router.routeToEditReadLink(link)
    }
    
    public func addReadLink(didAdded newItem: ReadLink) { }
    
    public func editReadLink(didEdit item: ReadLink) { }
}


// MARK: - ReadCollectionViewModelImple Interactor + edit collection

extension ReadCollectionViewItemsModelImple {
    
    private func item(for itemID: String) -> ReadItem? {
        let totalItems: [ReadItem] = (self.subjects.collections.value ?? []) + (self.subjects.links.value ?? [])
        return totalItems.first(where: { $0.uid == itemID })
    }
    
    private func requestSetupRemind(for itemID: String) {
        guard let item = self.item(for: itemID) else { return }
        
        self.router.routeToSetupRemind(for: item)
    }
    
    private func askConfirmCancelRemind(for itemID: String) {
        guard let item = self.item(for: itemID) else { return }
        
        let confirmCancel: () -> Void = { [weak self] in
            self?.cancelRemind(item)
        }
        guard let form = AlertBuilder(base: .init())
                .title("Cancel remind".localized)
                .message("Do you want to cancel this read remind?".localized)
                .confirmed(confirmCancel)
                .build()
        else { return }
        
        self.router.alertForConfirm(form)
    }
    
    private func cancelRemind(_ item: ReadItem) {
        
        let handleError: (Error) -> Void = { [weak self] error in
            self?.router.alertError(error)
        }
        self.remindUsecase.updateRemind(for: item, futureTime: nil)
            .subscribe(onError: handleError)
            .disposed(by: self.disposeBag)
    }
}


// MARK: - ReadCollectionViewModelImple Interactor + remove case

extension ReadCollectionViewItemsModelImple {
    
    private func requestRemoveReadItem(_ item: ReadItem) {
        
        let confirmed: () -> Void = { [weak self] in
            self?.removeItem(item)
        }
        
        guard let form = AlertBuilder(base: .init())
                .title("Delete item")
                .message("TBD confirm message")
                .confirmed(confirmed).build()
        else {
            return
        }
        self.router.alertForConfirm(form)
    }
    
    private func removeItem(_ item: ReadItem) {
        let handleRemoved: () -> Void = { [weak self] in
            self?.closeSceneIfCurrentCollectionRemoved(item)
        }
        
        let handleError: (Error) -> Void = { [weak self] error in
            self?.router.alertError(error)
        }
        
        self.readItemUsecase.removeItem(item)
            .subscribe(onSuccess: handleRemoved, onError: handleError)
            .disposed(by: self.disposeBag)
    }
    
    private func closeSceneIfCurrentCollectionRemoved(_ item: ReadItem) {
        guard item.uid == self.currentCollectionID else { return }
        self.router.returnToParent()
    }
}

// MARK: - ReadCollectionViewModelImple Presenter

extension ReadCollectionViewItemsModelImple {
    
    public var collectionTitle: Observable<String> {
        let isRootCollection = self.currentCollectionID == nil
        return isRootCollection
            ? .just("My Read Collections".localized)
            : self.subjects.currentCollection.compactMap { $0?.name }
    }
    
    public var currentSortOrder: Observable<ReadCollectionItemSortOrder> {
        return self.subjects.sortOrder
            .compactMap{ $0 }
            .distinctUntilChanged()
    }
        
    public var sections: Observable<[ReadCollectionItemSection]> {
        
        let asSections: (
            ReadCollection?, [ReadCollection], [ReadLink], ReadCollectionItemSortOrder,
            [String: ItemCategory], [String], Bool, Set<String>
        ) ->  [ReadCollectionItemSection]
        asSections = { currentCollection, collections, links, order, cateMap, customOrder, isShrinkMode, favorites in
            
            let attributeCell = currentCollection
                .map { ReadCollectionAttrCellViewModel(item: $0)
                    |> \.categories .~ $0.categoryIDs.compactMap{ cateMap[$0] }
                }
                .map { [$0] } ?? []
                .applyIsFavorite(favorites)
            
            let collectionCells: [ReadCollectionCellViewModel] = collections
                .sort(by: order, with: customOrder)
                .asCellViewModels(with: cateMap)
                .updateIsShrinkMode(isShrinkMode)
                .applyIsFavorite(favorites)
            
            let linkCells: [ReadLinkCellViewModel] = links
                .sort(by: order, with: customOrder)
                .asCellViewModels(with: cateMap)
                .updateIsShrinkMode(isShrinkMode)
                .applyIsFavorite(favorites)
            
            let sections: [ReadCollectionItemSection?] =  [
                attributeCell.asSectionIfNotEmpty(for: .attribute),
                collectionCells.asSectionIfNotEmpty(for: .collections),
                linkCells.asSectionIfNotEmpty(for: .links)
            ]
            return sections.compactMap { $0 }
        }
        
        return Observable.combineLatest(
            self.subjects.currentCollection,
            self.subjects.collections.compactMap { $0 },
            self.subjects.links.compactMap { $0 },
            self.subjects.sortOrder.compactMap { $0 },
            self.subjects.categoryMap,
            self.readItemUsecase.customOrder(for: self.substituteCollectionID),
            self.readItemUsecase.isShrinkModeOn,
            self.subjects.favoriteIDSet,
            resultSelector: asSections
        )
    }
    
    public func readLinkPreview(for linkID: String) -> Observable<LinkPreview> {
        let links = self.subjects.links.value
        guard let linkItem = links?.first(where: { $0.uid == linkID }) else {
            return .empty()
        }
        return self.readItemUsecase.loadLinkPreview(linkItem.link)
    }
    
    public var isEditable: Observable<Bool> {
        let isRootCollection = self.isRootCollection
        let checkIsEditableCollectionOrRoot: (ReadCollection?) -> Bool = { collection in
            let isNotRootAndCollectionInfoReady = isRootCollection == false && collection != nil
            return isRootCollection || isNotRootAndCollectionInfoReady
        }
        return self.subjects.currentCollection
            .map(checkIsEditableCollectionOrRoot)
            .distinctUntilChanged()
    }
    
    public func contextAction(for item: ReadItemCellViewModel,
                              isLeading: Bool) -> [ReadCollectionItemSwipeContextAction]? {
        let favoritesSet = self.subjects.favoriteIDSet.value
        switch item {
        case _ where isLeading == false:
            return [.delete, .edit]
            
        case let collection as ReadCollectionCellViewModel:
            return [
                .remind(isOn: collection.remindTime != nil),
                .favorite(isFavorite: favoritesSet.contains(item.uid))
            ]
            
        case let link as ReadLinkCellViewModel:
            return [
                .markAsRead(isRed: link.isRed),
                .remind(isOn: link.remindTime != nil),
                .favorite(isFavorite: favoritesSet.contains(item.uid))
            ]
            
        default: return nil
        }
    }
}

extension Array where Element: ReadItemCellViewModel {
    
    func applyIsFavorite(_ favorites: Set<String>) -> Array {
        return self.map { cvm in
            return cvm |> \.isFavorite .~ favorites.contains(cvm.uid)
        }
    }
}
