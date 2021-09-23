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


// MARK: - ReadCollectionViewModel

public protocol ReadCollectionViewModel: AnyObject {

    // interactor
    func reloadCollectionItems()
    func toggleShrinkListStyle()
    func requestChangeOrder()
    func openItem(_ itemID: String)
    func requestMakeNewCollection()
    func requestAddNewLink()
    
    
    // presenter
    var isShrinkMode: Observable<Bool> { get }
    var currentSortOrder: Observable<ReadCollectionItemSortOrder> { get }
    var cellViewModels: Observable<[ReadItemCellViewModel]> { get }
//    func linkPreviewThumbnail(for linkID: String) -> Observable<ImageSource?>
}


// MARK: - ReadCollectionViewModelImple

public final class ReadCollectionViewModelImple: ReadCollectionViewModel {
    
    private let collectionID: String
    private let readItemUsecase: ReadItemUsecase
    private let router: ReadCollectionRouting
    
    public init(collectionID: String,
                readItemUsecase: ReadItemUsecase,
                router: ReadCollectionRouting) {
        self.collectionID = collectionID
        self.readItemUsecase = readItemUsecase
        self.router = router
        
        self.internalBinding()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
        let isShrinkModeIsOn = BehaviorRelay<Bool?>(value: nil)
        let sortOrder = BehaviorRelay<ReadCollectionItemSortOrder?>(value: nil)
        let collections = BehaviorRelay<[ReadCollection]?>(value: nil)
        let links = BehaviorRelay<[ReadLink]?>(value: nil)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private func internalBinding() {
        
        let setupLatestsShrinkModeFlag: (Bool) -> Void = { [weak self] isOn in
            self?.subjects.isShrinkModeIsOn.accept(isOn)
        }
        self.readItemUsecase
            .loadShrinkModeIsOnOption()
            .subscribe(onSuccess: setupLatestsShrinkModeFlag)
            .disposed(by: self.disposeBag)
        
        let setupLatestSortOrder: (ReadCollectionItemSortOrder) -> Void = { [weak self] order in
            self?.subjects.sortOrder.accept(order)
        }
        self.readItemUsecase
            .loadLatestSortOption(for: self.collectionID)
            .subscribe(onSuccess: setupLatestSortOrder)
            .disposed(by: self.disposeBag)
    }
}


// MARK: - ReadCollectionViewModelImple Interactor

extension ReadCollectionViewModelImple {
    
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

extension ReadCollectionViewModelImple {
    
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
    
    public var cellViewModels: Observable<[ReadItemCellViewModel]> {
        
        let asCellViewModels: ([ReadCollection], [ReadLink], Bool, ReadCollectionItemSortOrder) ->  [ReadItemCellViewModel]
        asCellViewModels = { collections, links, isShrink, order in
            let collectionSection = collections.sort(by: order).asCellViewModels(isShrink: isShrink)
            let linkSection = links.sort(by: order).asCellViewModels(isShrink: isShrink)
            
            return collectionSection.appendSectionHeaderIfNotEmpty("Collections")
                + linkSection.appendSectionHeaderIfNotEmpty("Links")
        }
        
        return Observable.combineLatest(
            self.subjects.collections.compactMap { $0 },
            self.subjects.links.compactMap { $0 },
            self.subjects.isShrinkModeIsOn.compactMap { $0 },
            self.subjects.sortOrder.compactMap { $0 },
            resultSelector: asCellViewModels
        )
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
    
    func appendSectionHeaderIfNotEmpty(_ title: String) -> Array {
        guard self.isNotEmpty else { return [] }
        let header = ReadCollectionSectionCellViewModel(title: title)
        return [header] + self
    }
}
