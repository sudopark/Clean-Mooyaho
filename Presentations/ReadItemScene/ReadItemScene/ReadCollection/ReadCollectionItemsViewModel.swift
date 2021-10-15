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


public enum ReadCollectionItemSectionType: String {
    case attribute
    case collections
    case links
}

public struct ReadCollectionItemSection {
    let type: ReadCollectionItemSectionType
    let cellViewModels: [ReadItemCellViewModel]
}

public enum ReadCollectionItemSwipeContextAction {
    case edit
    case delete
}


// MARK: - ReadCollectionViewModel

public protocol ReadCollectionItemsViewModel: AnyObject {
    
    var currentCollectionID: String? { get }

    // interactor
    func reloadCollectionItems()
    func requestChangeOrder()
    func openItem(_ itemID: String)
    func addNewCollectionItem()
    func addNewReadLinkItem()
    func handleContextAction(for item: ReadItemCellViewModel,
                             action: ReadCollectionItemSwipeContextAction)
    func editCollection()
    
    
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
    private let categoryUsecase: ReadItemCategoryUsecase
    private let router: ReadCollectionRouting
    
    public init(collectionID: String?,
                readItemUsecase: ReadItemUsecase,
                categoryUsecase: ReadItemCategoryUsecase,
                router: ReadCollectionRouting) {
        self.currentCollectionID = collectionID
        self.readItemUsecase = readItemUsecase
        self.categoryUsecase = categoryUsecase
        self.router = router
        
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
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private func internalBinding() {
        self.loadLatestSortOrder()
        self.loadCurrentCollectionInfoIfNeed()
        self.bindRequireCategories()
    }
    
    private func loadLatestSortOrder() {
        let setupLatestSortOrder: (ReadCollectionItemSortOrder) -> Void = { [weak self] order in
            self?.subjects.sortOrder.accept(order)
        }
        self.readItemUsecase
            .loadLatestSortOption()
            .subscribe(onSuccess: setupLatestSortOrder)
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
        
        let totalItems: Observable<[ReadItem]> = Observable.merge(
            self.subjects.collections.compactMap { $0 },
            self.subjects.links.compactMap { $0 },
            self.subjects.currentCollection.compactMap { $0 }.map { [$0] }
        )
        let foldAsSet: (Set<String>, [ReadItem]) -> Set<String> = { acc, items in
            let newIDs = items.flatMap { $0.categoryIDs }
            return acc.union(newIDs)
        }
        let categoryIDSet = totalItems.scan(Set<String>(), accumulator: foldAsSet)
        let loadCategories: (Set<String>) -> Observable<[ItemCategory]> = { [weak self] idSet in
            guard let self = self else { return .empty() }
            return self.categoryUsecase.categories(for: Array(idSet))
        }
        categoryIDSet
            .distinctUntilChanged()
            .flatMapLatest(loadCategories)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] categories in
                let dict = categories.reduce(into: [String: ItemCategory]()) { $0[$1.uid] = $1 }
                self?.subjects.categoryMap.onNext(dict)
            })
            .disposed(by: self.disposeBag)
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
            self.router.showLinkDetail(linkItem.uid)
            
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
            // TODO: delete this collection
        }
        let cancel = ActionSheetForm.Action(text: "Cancel".localized, isCancel: true)
        
        let actions = self.isRootCollection ? [changeOrder, cancel] : [edit, changeOrder, delete, cancel]
        let form = ActionSheetForm(title: "Select action")
            |> \.actions .~ actions
        self.router.alertActionSheet(form)
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
    
    public func editReadCollection(didChange collection: ReadCollection) {
        
        guard collection.uid != self.currentCollectionID else {
            self.subjects.currentCollection.onNext(collection)
            return
        }
        
        guard collection.parentID == self.currentCollectionID else { return }
        
        let collections = self.subjects.collections.value ?? []
        
        func appendNewCollection() -> [ReadCollection] {
            return collections + [collection]
        }
        
        func updateCollection(_ index: Int) -> [ReadCollection] {
            return collections |> ix(index) .~ collection
        }
        
        let index = collections.firstIndex(where: { $0.uid == collection.uid })
        let newCollections = index.map { updateCollection($0) } ?? appendNewCollection()
        self.subjects.collections.accept(newCollections)
    }
}


// MARK: - ReadCollectionViewModelImple Interactor + edit read link

extension ReadCollectionViewItemsModelImple {
    
    public func addNewReadLinkItem() {
        
        let collectionID = self.currentCollectionID
        self.router.routeToAddNewLink(at: collectionID)
    }
    
    private func requestEditReadLink(_ item: ReadLinkCellViewModel) {
        guard let link = self.subjects.links.value?.first(where: { $0.uid == item.uid }) else { return }
        self.router.routeToEditReadLink(link)
    }
    
    public func addReadLink(didAdded newItem: ReadLink) {
        guard newItem.parentID == currentCollectionID else { return }
        let newLinks = [newItem] + (self.subjects.links.value ?? [])
        self.subjects.links.accept(newLinks)
    }
    
    public func editReadLink(didEdit item: ReadLink) {
        guard item.parentID == self.currentCollectionID,
              let links = self.subjects.links.value,
              let index = links.firstIndex(where:  { $0.uid == item.uid }) else { return }
        
        let newLinks = links |> ix(index) .~ item
        self.subjects.links.accept(newLinks)
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
            [String: ItemCategory], [String]
        ) ->  [ReadCollectionItemSection]
        asSections = { currentCollection, collections, links, order, cateMap, customOrder in
            
            let attributeCell = currentCollection
                .map { ReadCollectionAttrCellViewModel(item: $0)
                    |> \.categories .~ $0.categoryIDs.compactMap{ cateMap[$0] }
                }
                .map { [$0] } ?? []
            let collectionCells: [ReadCollectionCellViewModel] = collections
                .sort(by: order, with: customOrder)
                .asCellViewModels(with: cateMap)
            let linkCells: [ReadLinkCellViewModel] = links
                .sort(by: order, with: customOrder)
                .asCellViewModels(with: cateMap)
            
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
        guard item is ReadCollectionCellViewModel || item is ReadLinkCellViewModel else { return nil }
        return [.delete, .edit]
    }
}


private extension Array where Element: ReadItemCellViewModel {
    
    func asSectionIfNotEmpty(for type: ReadCollectionItemSectionType) -> ReadCollectionItemSection? {
        guard self.isNotEmpty else { return nil }
        return .init(type: type, cellViewModels: self)
    }
}
