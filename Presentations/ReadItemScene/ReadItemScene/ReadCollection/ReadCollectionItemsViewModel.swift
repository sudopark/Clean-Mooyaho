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


// MARK: - ReadCollectionViewModel

public protocol ReadCollectionItemsViewModel: AnyObject {

    // interactor
    func reloadCollectionItems()
    func toggleShrinkListStyle()
    func requestChangeOrder()
    func openItem(_ itemID: String)
    func requestMakeNewCollection()
    func requestAddNewLink()
    
    
    // presenter
    var collectionTitle: Observable<String> { get }
    var isShrinkMode: Observable<Bool> { get }
    var currentSortOrder: Observable<ReadCollectionItemSortOrder> { get }
    var sections: Observable<[ReadCollectionItemSection]> { get }
    func readLinkPreview(for linkID: String) -> Observable<LinkPreview>
}


// MARK: - ReadCollectionViewModelImple

public final class ReadCollectionViewItemsModelImple: ReadCollectionItemsViewModel {
    
    private let selectedCollectionID: String?
    private let readItemUsecase: ReadItemUsecase
    private let router: ReadCollectionRouting
    
    public init(collectionID: String?,
                readItemUsecase: ReadItemUsecase,
                router: ReadCollectionRouting) {
        self.selectedCollectionID = collectionID
        self.readItemUsecase = readItemUsecase
        self.router = router
        
        self.internalBinding()
    }
    
    private var collectionID: String {
        return self.selectedCollectionID ?? ReadCollection.rootID
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
        let isShrinkModeIsOn = BehaviorRelay<Bool?>(value: nil)
        let currentCollection = BehaviorSubject<ReadCollection?>(value: nil)
        let sortOrder = BehaviorRelay<ReadCollectionItemSortOrder?>(value: nil)
        let collections = BehaviorRelay<[ReadCollection]?>(value: nil)
        let links = BehaviorRelay<[ReadLink]?>(value: nil)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private func internalBinding() {
        self.loadIsShrinkMode()
        self.loadLatestSortOrder()
        self.loadCurrentCollectionInfoIfNeed()
    }
    
    private func loadIsShrinkMode() {
        let setupLatestsShrinkModeFlag: (Bool) -> Void = { [weak self] isOn in
            self?.subjects.isShrinkModeIsOn.accept(isOn)
        }
        self.readItemUsecase
            .loadShrinkModeIsOnOption()
            .subscribe(onSuccess: setupLatestsShrinkModeFlag)
            .disposed(by: self.disposeBag)
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
    
    public func toggleShrinkListStyle() {
        guard let oldValue = self.subjects.isShrinkModeIsOn.value else { return }
        let newValue = oldValue.invert()
        self.subjects.isShrinkModeIsOn.accept(newValue)
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
    
    public func requestMakeNewCollection() {
        
        let collectionCreated: (ReadCollection) -> Void = { [weak self] newCollection in
            guard let self = self else { return }
            let newCollections = [newCollection] + (self.subjects.collections.value ?? [])
            self.subjects.collections.accept(newCollections)
        }
        self.router.routeToMakeNewCollectionScene(collectionCreated)
    }
    
    public func requestAddNewLink() {
        
        let linkItemAdded: (ReadLink) -> Void = { [weak self] newLink in
            guard let self = self else { return }
            let newLinks = [newLink] + (self.subjects.links.value ?? [])
            self.subjects.links.accept(newLinks)
        }
        self.router.routeToAddNewLink(at: self.collectionID, linkItemAdded)
    }
}


// MARK: - ReadCollectionViewModelImple Presenter

extension ReadCollectionViewItemsModelImple {
    
    public var collectionTitle: Observable<String> {
        let isRootCollection = self.selectedCollectionID == nil
        return isRootCollection
            ? .just("My Read Collections".localized)
            : self.subjects.currentCollection.compactMap { $0?.name }
    }
    
    public var isShrinkMode: Observable<Bool> {
        return self.subjects.isShrinkModeIsOn
            .compactMap{ $0 }
            .distinctUntilChanged()
    }
    
    public var currentSortOrder: Observable<ReadCollectionItemSortOrder> {
        return self.subjects.sortOrder
            .compactMap{ $0 }
            .distinctUntilChanged()
    }
        
    public var sections: Observable<[ReadCollectionItemSection]> {
        
        let asSections: (ReadCollection?, [ReadCollection], [ReadLink], Bool, ReadCollectionItemSortOrder) ->  [ReadCollectionItemSection]
        asSections = { currentCollection, collections, links, isShrink, order in
            
            let attributeCell: [ReadItemCellViewModel] = currentCollection
                .map{ [ReadCollectionAttrCellViewModel(collection: $0)] } ?? []
            let collectionCells = collections.sort(by: order).asCellViewModels(isShrink: isShrink)
            let linkCells = links.sort(by: order).asCellViewModels(isShrink: isShrink)
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
            self.subjects.isShrinkModeIsOn.compactMap { $0 },
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
    
    func asCellViewModels(isShrink: Bool) -> [ReadItemCellViewModel] {
        let transform: (ReadItem) -> ReadItemCellViewModel? = { item in
            switch item {
            case let collection as ReadCollection:
                return ReadCollectionCellViewModel(collection: collection)
                    |> \.isShrink .~ isShrink
                
            case let link as ReadLink:
                return ReadLinkCellViewModel(link: link)
                    |> \.isShrink .~ isShrink
                
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
