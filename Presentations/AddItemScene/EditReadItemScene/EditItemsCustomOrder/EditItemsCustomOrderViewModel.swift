//
//  EditItemsCustomOrderViewModel.swift
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/15.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - cellViewMdoels

public struct EditCollectionItemOrderCellViewModel: ReadItemCellViewModelType {
    
    public typealias Item = ReadCollection
    
    public let uid: String
    public let name: String
    public let description: String?
    
    public init(item: ReadCollection) {
        self.uid = item.uid
        self.name = item.name
        self.description = item.collectionDescription
    }
    
    public var presetingID: Int { self.uid.hashValue }
}

public struct EditLinkItemOrderCellViewModel: ReadItemCellViewModelType {
    
    public typealias Item = ReadLink
    
    public var uid: String
    public let customName: String?
    public let address: String
    
    public init(item: ReadLink) {
        self.uid = item.uid
        self.customName = item.customName
        self.address = item.link
    }
    
    public var presetingID: Int { self.uid.hashValue }
}

public struct EditOrderItemsSection: Equatable {
    let title: String
    let cellViewModels: [ReadItemCellViewModel]
    
    public static func == (_ lhs: Self, _ rhs: Self) -> Bool {
        return lhs.title == rhs.title
            && lhs.cellViewModels.map { $0.presetingID } == rhs.cellViewModels.map { $0.presetingID }
    }
}


// MARK: - EditItemsCustomOrderViewModel

public protocol EditItemsCustomOrderViewModel: AnyObject {

    // interactor
    func loadCollectionItemsWithCustomOrder()
    func itemMoved(from: IndexPath, to: IndexPath)
    func confirmSave()
    
    // presenter
    func readLinkPreview(for address: String) -> Observable<LinkPreview>
    var sections: Observable<[EditOrderItemsSection]> { get }
    var isConfirmable: Observable<Bool> { get }
    var isSaving: Observable<Bool> { get }
}


// MARK: - EditItemsCustomOrderViewModelImple

public final class EditItemsCustomOrderViewModelImple: EditItemsCustomOrderViewModel {
    
    private let currentCollectionID: String?
    private let readItemUsecase: ReadItemUsecase
    private let router: EditItemsCustomOrderRouting
    private weak var listener: EditItemsCustomOrderSceneListenable?
    
    public init(collectionID: String?,
                readItemUsecase: ReadItemUsecase,
                router: EditItemsCustomOrderRouting,
                listener: EditItemsCustomOrderSceneListenable?) {
        self.currentCollectionID = collectionID
        self.readItemUsecase = readItemUsecase
        self.router = router
        self.listener = listener
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
        let collections = BehaviorRelay<[ReadCollection]?>(value: nil)
        let links = BehaviorRelay<[ReadLink]?>(value: nil)
        let isSaving = BehaviorRelay<Bool>(value: false)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - EditItemsCustomOrderViewModelImple Interactor

extension EditItemsCustomOrderViewModelImple {
    
    public func loadCollectionItemsWithCustomOrder() {
        
        let prepareCustomOrder = self.readItemUsecase.customOrder(for: self.substituteCollectionID).take(1)
        let thenLoadItems: ([String]) -> Observable<([ReadCollection], [ReadLink])> = { [weak self] customOrder in
            guard let self = self else { return .empty() }
            return self.loadItemsWithSortedSection(by: customOrder)
        }
        
        let updateList: ([ReadCollection], [ReadLink]) -> Void = { [weak self] collections, links in
            self?.subjects.collections.accept(collections)
            self?.subjects.links.accept(links)
        }
        let handleError: (Error) -> Void = { [weak self] error in
            self?.router.alertError(error)
        }
            
        prepareCustomOrder
            .flatMap(thenLoadItems)
            .subscribe(onNext: updateList, onError: handleError)
            .disposed(by: self.disposeBag)
    }
    
    private func loadItemsWithSortedSection(by customOrder: [String]) -> Observable<([ReadCollection], [ReadLink])> {
        let loadItems = self.currentCollectionID
            .map { self.readItemUsecase.loadCollectionItems($0) } ?? self.readItemUsecase.loadMyItems()
        
        let splitItems: ([ReadItem]) -> ([ReadCollection], [ReadLink]) = { items in
            return (items.compactMap { $0 as? ReadCollection }, items.compactMap { $0 as? ReadLink })
        }
        let sort: ([ReadCollection], [ReadLink]) -> ([ReadCollection], [ReadLink]) = { collections, links in
            return (
                collections.sort(by: .byCustomOrder, with: customOrder),
                links.sort(by: .byCustomOrder, with: customOrder)
            )
        }
        
        return loadItems
            .map(splitItems)
            .map(sort)
    }
    
    public func itemMoved(from: IndexPath, to: IndexPath) {
        
        guard from.section == to.section else { return }
        
        func reorderCollection() {
            guard var collections = self.subjects.collections.value,
                  collections.isBothInSafeRange(from.row, to.row) else { return }
            let moving = collections.remove(at: from.row)
            collections.insert(moving, at: to.row)
            self.subjects.collections.accept(collections)
        }
        
        func reorderLinkItems() {
            guard var links = self.subjects.links.value,
                  links.isBothInSafeRange(from.row, to.row) else { return }
            let moving = links.remove(at: from.row)
            links.insert(moving, at: to.row)
            self.subjects.links.accept(links)
        }
        
        let (section, isEmptyColletion) = (from.section, self.subjects.collections.value?.isEmpty ?? true)
        let shouldMoveLinkSection = section == 1 || (section == 0 && isEmptyColletion)
        return shouldMoveLinkSection ? reorderLinkItems() : reorderCollection()
    }
    
    public func confirmSave() {
        
        guard self.subjects.isSaving.value == false,
              let collections = self.subjects.collections.value,
              let links = self.subjects.links.value else { return }
        let ids = collections.map { $0.uid } + links.map { $0.uid }
        
        let didUpdated: () -> Void = { [weak self] in
            self?.subjects.isSaving.accept(false)
            self?.router.closeScene(animated: true, completed: nil)
        }
        let handleError: (Error) -> Void = { [weak self] error in
            self?.subjects.isSaving.accept(false)
            self?.router.alertError(error)
        }
        
        self.subjects.isSaving.accept(true)
        self.readItemUsecase.updateCustomOrder(for: self.substituteCollectionID, itemIDs: ids)
            .subscribe(onSuccess: didUpdated, onError: handleError)
            .disposed(by: self.disposeBag)
    }
}


// MARK: - EditItemsCustomOrderViewModelImple Presenter

extension EditItemsCustomOrderViewModelImple {
    
    public var isConfirmable: Observable<Bool> {
        return Observable.combineLatest(self.subjects.collections, self.subjects.links)
            .map { $0 != nil && $1 != nil }
            .distinctUntilChanged()
    }
    
    public func readLinkPreview(for address: String) -> Observable<LinkPreview> {
        return self.readItemUsecase.loadLinkPreview(address)
    }
    
    public var sections: Observable<[EditOrderItemsSection]> {
        
        let asSections: ([ReadCollection], [ReadLink]) -> [EditOrderItemsSection]
        asSections = { collections, links in
            let collectionCells: [EditCollectionItemOrderCellViewModel] = collections
                .asCellViewModels()
            let linkCells: [EditLinkItemOrderCellViewModel] = links
                .asCellViewModels()
            let sections: [EditOrderItemsSection?] = [
                collectionCells.asSectionIfNotEmpty(for: "Collections".localized),
                linkCells.asSectionIfNotEmpty(for: "Links".localized)
            ]
            return sections.compactMap { $0 }
        }
        return Observable.combineLatest(
            self.subjects.collections.compactMap { $0 },
            self.subjects.links.compactMap { $0 },
            resultSelector: asSections
        )
        .distinctUntilChanged()
    }
    
    public var isSaving: Observable<Bool> {
        return self.subjects.isSaving
            .distinctUntilChanged()
    }
}

private extension Array {
    
    func isBothInSafeRange(_ index1: Int, _ index2: Int) -> Bool {
        let range = (0..<self.count)
        return range ~= index1 && range ~= index2
    }
}

private extension Array where Element: ReadItemCellViewModel {
    
    func asSectionIfNotEmpty(for title: String) -> EditOrderItemsSection? {
        guard self.isNotEmpty else { return nil }
        return .init(title: title, cellViewModels: self)
    }
}
