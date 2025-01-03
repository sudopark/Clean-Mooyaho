//
//  NavigateCollectionViewModel.swift
//  ReadItemScene
//
//  Created sudo.park on 2021/10/26.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


public struct NavigateCollectionCellViewModel: Equatable {
    
    let uid: String
    let name: String
    let description: String?
    let isSelectable: Bool
    
    init(collection: ReadCollection, isSelectable: Bool = true) {
        self.uid = collection.uid
        self.name = collection.name
        self.description = collection.collectionDescription
        self.isSelectable = isSelectable
    }
}


// MARK: - NavigateCollectionViewModel

public protocol NavigateCollectionViewModel: AnyObject, Sendable {

    // interactor
    func reloadCollections()
    func requestPrepareParentIfNeed()
    func moveToSubCollection(_ collectionID: String)
    func confirmSelect()
    
    // presenter
    var collectionTitle: Observable<String> { get }
    var cellViewModels: Observable<[NavigateCollectionCellViewModel]> { get }
    var confirmTitle: Observable<String> { get }
    var isParentChangable: Bool { get }
}


// MARK: - NavigateCollectionViewModelImple

public class NavigateCollectionViewModelImple: NavigateCollectionViewModel, @unchecked Sendable {
    
    let readItemUsecase: ReadItemUsecase
    let router: NavigateCollectionRouting
    private let unselectableCollectionID: String?
    private weak var listener: NavigateCollectionSceneListenable?
    private weak var coordinator: CollectionInverseNavigationCoordinating?
    
    public init(currentCollection: ReadCollection?,
                unselectableCollectionID: String?,
                readItemUsecase: ReadItemUsecase,
                router: NavigateCollectionRouting,
                listener: NavigateCollectionSceneListenable?,
                coordinator: CollectionInverseNavigationCoordinating?) {
        
        self.readItemUsecase = readItemUsecase
        self.unselectableCollectionID = unselectableCollectionID
        self.router = router
        self.listener = listener
        self.coordinator = coordinator
        
        self.subjects.currentCollection.accept(currentCollection)
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects: Sendable {
        
        let currentCollection = BehaviorRelay<ReadCollection?>(value: nil)
        let collections = BehaviorRelay<[ReadCollection]?>(value: nil)
    }
    
    private let subjects = Subjects()
    let disposeBag = DisposeBag()

    private func handleError() -> (Error) -> Void {
        return { [weak self] error in
            self?.router.alertError(error)
        }
    }
    
    public func confirmSelect() {
        
        let collection = self.subjects.currentCollection.value
        self.router.closeScene(animated: true) { [weak self] in
            self?.listener?.navigateCollection(didSelectCollection: collection)
        }
    }
    
    public var isParentChangable: Bool { true }
}


// MARK: - NavigateCollectionViewModelImple Interactor

extension NavigateCollectionViewModelImple {
    
    public func reloadCollections() {
        
        let loaded: ([ReadCollection]) -> Void = { [weak self] collections in
            self?.subjects.collections.accept(collections)
        }
        let loading = self.subjects.currentCollection.value
            .map { self.readItemUsecase.loadCollectionItems($0.uid) }
            ?? self.readItemUsecase.loadMyItems()
     
        let filtering: ([ReadItem]) -> [ReadCollection] = { items in
            return items.compactMap { $0 as? ReadCollection }
        }
        
        loading
            .map(filtering)
            .subscribe(onNext: loaded, onError: self.handleError())
            .disposed(by: self.disposeBag)
    }
    
    public func requestPrepareParentIfNeed() {
        
        guard let parentID = self.subjects.currentCollection.value?.parentID
        else { return }
        let loadParent = self.readItemUsecase.loadCollectionInfo(parentID)
        let thenRequestPreapre: (ReadCollection) -> Void = { [weak self] parent in
            self?.coordinator?.inverseNavigating(prepareParent: parent)
        }
        
        loadParent
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: thenRequestPreapre)
            .disposed(by: self.disposeBag)
    }
    
    public func moveToSubCollection(_ collectionID: String) {
        guard let collections = self.subjects.collections.value,
              let collection = collections.first(where: { $0.uid == collectionID })
        else { return }
        
        let isSelectable = collectionID != self.unselectableCollectionID
        return isSelectable
            ? self.router
                .moveToSubCollection(collection, with: self.unselectableCollectionID, listener: self.listener)
            : self.router.showToast("You cannot select the same reading list.".localized)
    }
}


// MARK: - NavigateCollectionViewModelImple Presenter

extension NavigateCollectionViewModelImple {
    
    public var collectionTitle: Observable<String> {
        let transform: (ReadCollection?) -> String = { collection in
            return collection?.name ?? "My Read Collections".localized
        }
        return self.subjects.currentCollection
            .map(transform)
            .distinctUntilChanged()
    }
    
    public var cellViewModels: Observable<[NavigateCollectionCellViewModel]> {
        let unselectableCollectionID = self.unselectableCollectionID
        return self.subjects.collections
            .compactMap { $0?.asCellViewModels(with: unselectableCollectionID) }
            .distinctUntilChanged()
    }
    
    public var confirmTitle: Observable<String> {
        
        let transform: (String?) -> String = { name in
            return name.map { "Select_collection".localized(with: $0) }
            ?? "Select current collection".localized
        }
        
        return self.subjects.currentCollection
            .map { $0?.name }
            .map(transform)
            .distinctUntilChanged()
    }
}

private extension Array where Element == ReadCollection {
    
    func asCellViewModels(with unselectableCollectionID: String?) -> [NavigateCollectionCellViewModel] {
        return self.map {
            return NavigateCollectionCellViewModel(
                collection: $0,
                isSelectable: $0.uid != unselectableCollectionID
            )
        }
    }
}
