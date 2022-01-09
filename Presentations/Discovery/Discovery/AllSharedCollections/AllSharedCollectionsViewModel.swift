//
//  AllSharedCollectionsViewModel.swift
//  DiscoveryScene
//
//  Created sudo.park on 2021/12/08.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay
import Prelude
import Optics

import Domain
import CommonPresenting


public struct AllSharedCollectionCellViewModel: Equatable {
    
    let shareID: String
    let collectionName: String
    let ownerID: String
    let description: String?
    var categories: [ItemCategory] = []
    
    init?(_ collection: SharedReadCollection) {
        guard let ownerID = collection.ownerID else { return nil }
        self.shareID = collection.shareID
        self.ownerID = ownerID
        self.collectionName = collection.name
        self.description = collection.description
    }
}


// MARK: - AllSharedCollectionsViewModel

public protocol AllSharedCollectionsViewModel: AnyObject {

    // interactor
    func reloadCollections()
    func loadMoreCollections()
    func selectCollection(sharedID: String)
    func removeCollection(sharedID: String)
    
    // presenter
    var cellViewModels: Observable<[AllSharedCollectionCellViewModel]> { get }
    func sharedOwnerInfo(for memberID: String) -> Observable<Member>
}


// MARK: - AllSharedCollectionsViewModelImple

public final class AllSharedCollectionsViewModelImple: AllSharedCollectionsViewModel {
    
    private let pagingUsecase: SharedReadCollectionPagingUsecase
    private let updateUsecase: SharedReadCollectionUpdateUsecase
    private let memberUsecase: MemberUsecase
    private let categoryUsecase: ReadItemCategoryUsecase
    private let router: AllSharedCollectionsRouting
    private weak var listener: AllSharedCollectionsSceneListenable?
    
    public init(pagingUsecase: SharedReadCollectionPagingUsecase,
                updateUsecase: SharedReadCollectionUpdateUsecase,
                memberUsecase: MemberUsecase,
                categoryUsecase: ReadItemCategoryUsecase,
                router: AllSharedCollectionsRouting,
                listener: AllSharedCollectionsSceneListenable?) {
        
        self.pagingUsecase = pagingUsecase
        self.updateUsecase = updateUsecase
        self.memberUsecase = memberUsecase
        self.categoryUsecase = categoryUsecase
        self.router = router
        self.listener = listener
        
        self.bindSharedOwners()
        self.bindCategories()
        self.bindCollections()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
        let collections = BehaviorRelay<[SharedReadCollection]?>(value: nil)
        let removedIDSet = BehaviorRelay<Set<String>>(value: [])
        let categoryMap = BehaviorRelay<[String: ItemCategory]>(value: [:])
        let ownersMap = BehaviorRelay<[String: Member]>(value: [:])
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private func bindSharedOwners() {
        
        let ownerIDSet = self.subjects.collections.compactMap { $0 }
            .map { $0.compactMap { $0.ownerID} }
            .map { Set($0) }
        let asMember: (Set<String>) -> Observable<[String: Member]> = { [weak self] memberIDSet in
            guard let self = self else { return .empty() }
            let uniqueIDs = Array(memberIDSet)
            return self.memberUsecase.members(for: uniqueIDs)
        }
        ownerIDSet
            .flatMap(asMember)
            .subscribe(onNext: { [weak self] memberMap in
                self?.subjects.ownersMap.accept(memberMap)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindCategories() {
        
        let itemSource: Observable<[ItemCategoryPresentable]> = self.subjects.collections.compactMap { $0 }
        
        let updateSubject: ([String: ItemCategory]) -> Void = { [weak self] cateMap in
            self?.subjects.categoryMap.accept(cateMap)
        }
        self.categoryUsecase
            .requireCategoryMap(from: [itemSource])
            .subscribe(onNext: updateSubject)
            .disposed(by: self.disposeBag)
    }
    
    private func bindCollections() {
        
        let updateCollections: ([SharedReadCollection]) -> Void = { [weak self] collections in
            self?.subjects.collections.accept(collections)
        }
        self.pagingUsecase.collections
            .subscribe(onNext: updateCollections)
            .disposed(by: self.disposeBag)
    }
}


// MARK: - AllSharedCollectionsViewModelImple Interactor

extension AllSharedCollectionsViewModelImple {
    
    public func reloadCollections() {
        self.pagingUsecase.reloadSharedCollections()
    }
    
    public func loadMoreCollections() {
        self.pagingUsecase.loadMoreSharedCollections()
    }
    
    public func selectCollection(sharedID: String) {
        guard let collections = self.subjects.collections.value,
              let collection = collections.first(where: { $0.shareID == sharedID })
        else {
            return
        }
        self.router.switchToSharedCollection(collection)
    }
    
    public func removeCollection(sharedID: String) {
        
        let confirmed: () -> Void = { [weak self] in
            self?.confirmRemove(sharedID)
        }
        
        guard let form = AlertBuilder(base: .init())
                .title("Remove".localized)
                .message("Would you like to remove the reading list from the shared list? (You can re-add it at any time with the shared URL.)".localized)
                .confirmed(confirmed)
                .build()
        else {
            return
        }
        self.router.alertForConfirm(form)
    }
    
    private func confirmRemove(_ shareID: String) {
        
        let applyRemoved: () -> Void = { [weak self] in
            guard let self = self else { return }
            let newIDSet = self.subjects.removedIDSet.value.union([shareID])
            self.subjects.removedIDSet.accept(newIDSet)
        }
        
        let handleError: (Error) -> Void = { [weak self] error in
            self?.router.alertError(error)
        }
        
        self.updateUsecase.removeFromSharedList(shareID: shareID)
            .subscribe(onSuccess: applyRemoved, onError: handleError)
            .disposed(by: self.disposeBag)
    }
}


// MARK: - AllSharedCollectionsViewModelImple Presenter

extension AllSharedCollectionsViewModelImple {
    
    public var cellViewModels: Observable<[AllSharedCollectionCellViewModel]> {
        
        let asCellViewModels: (
            [SharedReadCollection],
            [String: ItemCategory],
            Set<String>
        ) -> [AllSharedCollectionCellViewModel]
        
        asCellViewModels = { collections, categoryMap, removeIDSet in
            return collections
                .filter { removeIDSet.contains($0.shareID) == false }
                .asCellViewModels(categoryMap)
        }
        
        return Observable
            .combineLatest(self.subjects.collections.compactMap { $0 },
                           self.subjects.categoryMap,
                           self.subjects.removedIDSet,
                           resultSelector: asCellViewModels)
            .distinctUntilChanged()
    }
    
    public func sharedOwnerInfo(for memberID: String) -> Observable<Member> {
        return self.subjects.ownersMap
            .compactMap { $0[memberID] }
    }
}

private extension Array where Element == SharedReadCollection {
    
    func asCellViewModels(_ categoryMap: [String: ItemCategory]) -> [AllSharedCollectionCellViewModel] {
        return self.compactMap { collection -> AllSharedCollectionCellViewModel? in
            guard let cellViewModel = AllSharedCollectionCellViewModel(collection) else { return nil }
            return cellViewModel
                |> \.categories .~ collection.categoryIDs.compactMap { categoryMap[$0] }
        }
    }
}
