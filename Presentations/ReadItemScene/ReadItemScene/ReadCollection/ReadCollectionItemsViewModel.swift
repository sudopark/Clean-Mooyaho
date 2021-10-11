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
import CoreMIDI


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
    
    
    // presenter
    var collectionTitle: Observable<String> { get }
    var currentSortOrder: Observable<ReadCollectionItemSortOrder> { get }
    var sections: Observable<[ReadCollectionItemSection]> { get }
    func readLinkPreview(for linkID: String) -> Observable<LinkPreview>
    func itemCategories(_ categoryIDs: [String]) -> Observable<[ItemCategory]>
    var isEditable: Bool { get }
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
    
    private var collectionID: String {
        return self.currentCollectionID ?? ReadCollection.rootID
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
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private func internalBinding() {
        self.loadLatestSortOrder()
        self.loadCurrentCollectionInfoIfNeed()
    }
    
    private func loadLatestSortOrder() {
        let setupLatestSortOrder: (ReadCollectionItemSortOrder) -> Void = { [weak self] order in
            self?.subjects.sortOrder.accept(order)
        }
        self.readItemUsecase
            .loadLatestSortOption(for: self.collectionID)
            .subscribe(onSuccess: setupLatestSortOrder)
            .disposed(by: self.disposeBag)
    }
    
    private func loadCurrentCollectionInfoIfNeed() {
        guard self.collectionID != ReadCollection.rootID else { return }
        
        let updateCurrentCollection: (ReadCollection) -> Void = { [weak self] collection in
            self?.subjects.currentCollection.onNext(collection)
        }
        self.readItemUsecase
            .loadCollectionInfo(self.collectionID)
            .subscribe(onNext: updateCurrentCollection)
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
        let loadItems = self.collectionID == ReadCollection.rootID
            ? self.readItemUsecase.loadMyItems()
            : self.readItemUsecase.loadCollectionItems(self.collectionID)
            
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
            return [collection] + collections
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
        guard newItem.parentID == collectionID else { return }
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
        
        let asSections: (ReadCollection?, [ReadCollection], [ReadLink], ReadCollectionItemSortOrder) ->  [ReadCollectionItemSection]
        asSections = { currentCollection, collections, links, order in
            
            let attributeCell: [ReadItemCellViewModel] = currentCollection
                .map{ [ReadCollectionAttrCellViewModel(collection: $0)] } ?? []
            let collectionCells = collections.sort(by: order).asCellViewModels()
            let linkCells = links.sort(by: order).asCellViewModels()
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
    
    public var isEditable: Bool { self.currentCollectionID != nil }
    
    public func itemCategories(_ categoryIDs: [String]) -> Observable<[ItemCategory]> {
        return self.categoryUsecase.categories(for: categoryIDs)
            .distinctUntilChanged()
    }
    
    public func contextAction(for item: ReadItemCellViewModel,
                              isLeading: Bool) -> [ReadCollectionItemSwipeContextAction]? {
        guard item is ReadCollectionCellViewModel || item is ReadLinkCellViewModel else { return nil }
        return [.delete, .edit]
    }
}

private extension Array where Element: ReadItem {
    
    func sort(by order: ReadCollectionItemSortOrder) -> Array {
        
        let compare: (Element, Element) -> Bool = { lhs, rhs in
            switch order {
            case let .byCreatedAt(isAscending):
                return isAscending
                    ? lhs.createdAt < rhs.createdAt
                    : lhs.createdAt > rhs.createdAt
                
            case let .byLastUpdatedAt(isAscending):
                return isAscending
                    ? lhs.lastUpdatedAt < rhs.lastUpdatedAt
                    : lhs.lastUpdatedAt > rhs.lastUpdatedAt
                
            case let .byPriority(isAscending):
                return isAscending
                    ? ReadPriority.isAscendingOrder(lhs.priority, rhs: rhs.priority)
                    : ReadPriority.isDescendingOrder(lhs.priority, rhs: rhs.priority)
                
            case .byCustomOrder: return true
            }
        }
        return self.sorted(by: compare)
    }
    
    func asCellViewModels() -> [ReadItemCellViewModel] {
        let transform: (ReadItem) -> ReadItemCellViewModel? = { item in
            switch item {
            case let collection as ReadCollection:
                return ReadCollectionCellViewModel(collection: collection)
                
            case let link as ReadLink:
                return ReadLinkCellViewModel(link: link)
                
            default: return nil
            }
        }
        return self.compactMap(transform)
    }
}


private extension Array where Element == ReadItemCellViewModel {
    
    func asSectionIfNotEmpty(for type: ReadCollectionItemSectionType) -> ReadCollectionItemSection? {
        guard self.isNotEmpty else { return nil }
        return .init(type: type, cellViewModels: self)
    }
}
