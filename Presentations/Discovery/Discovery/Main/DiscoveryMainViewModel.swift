//
//  DiscoveryMainViewModel.swift
//  DiscoveryScene
//
//  Created sudo.park on 2021/11/14.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay
import Prelude
import Optics

import Domain
import CommonPresenting


// MARK: - DiscoveryMainViewModel

public struct LatestSharedCellViewMdoel: Equatable {
    
    let shareID: String
    let collectionName: String
    let shareOwnerID: String
    let description: String?
    var isFavorite: Bool = false
    var isCurrentCollection: Bool = false
    
    init?(collection: SharedReadCollection) {
        guard let ownerID = collection.ownerID else { return nil }
        self.shareOwnerID = ownerID
        self.shareID = collection.shareID
        self.collectionName = collection.name
        self.description = collection.description
    }
}

public enum SharedListIsEmpty: Equatable {
    case notEmpty
    case empty(signInNeed: Bool)
}

public protocol DiscoveryMainViewModel: AnyObject {

    // interactor
    func refresh()
    func selectCollection(_ shareID: String)
    func viewAllSharedCollections()
    func switchToMyCollection()
    
    // presenter
    var showSwitchToMyCollection: Bool { get }
    var cellViewModels: Observable<[LatestSharedCellViewMdoel]> { get }
    func shareOwner(for memberID: String) -> Observable<Member>
    var sharedListIsEmpty: Observable<SharedListIsEmpty> { get }
}


// MARK: - DiscoveryMainViewModelImple

public final class DiscoveryMainViewModelImple: DiscoveryMainViewModel {
    
    private let currentSharedCollectionShareID: String?
    private let sharedReadCollectionLoadUsecase: SharedReadCollectionLoadUsecase
    private let memberUsecase: MemberUsecase
    private let router: DiscoveryMainRouting
    private weak var listener: DiscoveryMainSceneListenable?
    
    public init(currentSharedCollectionShareID: String?,
                sharedReadCollectionLoadUsecase: SharedReadCollectionLoadUsecase,
                memberUsecase: MemberUsecase,
                router: DiscoveryMainRouting,
                listener: DiscoveryMainSceneListenable?) {
        self.currentSharedCollectionShareID = currentSharedCollectionShareID
        self.sharedReadCollectionLoadUsecase = sharedReadCollectionLoadUsecase
        self.memberUsecase = memberUsecase
        self.router = router
        self.listener = listener
        
        self.bindOwnerInfos()
        self.bindLatestSharedCollections()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
        
        let sharedCollections = BehaviorRelay<[SharedReadCollection]>(value: [])
        let ownersMap = BehaviorRelay<[String: Member]>(value: [:])
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private func bindLatestSharedCollections() {
        
        self.sharedReadCollectionLoadUsecase.lastestSharedReadCollections
            .subscribe(onNext: { [weak self] collections in
                self?.subjects.sharedCollections.accept(collections)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindOwnerInfos() {
        
        let memberSource = self.subjects.sharedCollections
            .map { $0.compactMap { $0.ownerID } }
        let asMembers: ([String]) -> Observable<[String: Member]> = { [weak self] memberIDs in
            guard let self = self else { return .empty() }
            let uniqueIDs = Array(Set(memberIDs))
            return self.memberUsecase.members(for: uniqueIDs)
        }
        memberSource
            .flatMap(asMembers)
            .subscribe(onNext: { [weak self] memberMap in
                self?.subjects.ownersMap.accept(memberMap)
            })
            .disposed(by: self.disposeBag)
    }
}


// MARK: - DiscoveryMainViewModelImple Interactor

extension DiscoveryMainViewModelImple {
    
    public func refresh() {
        self.sharedReadCollectionLoadUsecase.refreshLatestSharedReadCollection()
    }
    
    public func selectCollection(_ shareID: String) {
        let collections = self.subjects.sharedCollections.value
        guard let collection = collections.first(where: { $0.shareID == shareID }) else { return }
        self.listener?.switchToSharedCollectionDetail(collection)
    }
    
    public func viewAllSharedCollections() {
        self.router.viewAllSharedCollections()
    }
    
    public func switchToMyCollection() {
        self.listener?.switchToMyReadCollections()
    }
}


// MARK: - DiscoveryMainViewModelImple Presenter

extension DiscoveryMainViewModelImple {
    
    public var showSwitchToMyCollection: Bool {
        return self.currentSharedCollectionShareID != nil
    }
    
    public var cellViewModels: Observable<[LatestSharedCellViewMdoel]> {
        let currentShareID = self.currentSharedCollectionShareID
        let asCellViewModels: ([SharedReadCollection]) -> [LatestSharedCellViewMdoel]
        asCellViewModels = { collections in
            return collections.compactMap { LatestSharedCellViewMdoel(collection: $0) }
        }
        let markCurrentCollection: ([LatestSharedCellViewMdoel]) -> [LatestSharedCellViewMdoel]
        markCurrentCollection = { models in
            return models.map { $0 |> \.isCurrentCollection .~ ($0.shareID == currentShareID) }
        }
        
        return self.subjects.sharedCollections
            .map(asCellViewModels)
            .map(markCurrentCollection)
            .distinctUntilChanged()
    }
    
    public func shareOwner(for memberID: String) -> Observable<Member> {
        return self.subjects.ownersMap
            .compactMap { $0[memberID] }
            .distinctUntilChanged(Member.compareNameAndIcon(_:_:))
    }
    
    public var sharedListIsEmpty: Observable<SharedListIsEmpty> {
        let transform: ([LatestSharedCellViewMdoel], Member?) -> SharedListIsEmpty = { models, member in
            guard member != nil else { return .empty(signInNeed: true) }
            return models.isEmpty ? .empty(signInNeed: false) : .notEmpty
        }
        
        return Observable
            .combineLatest(cellViewModels, self.memberUsecase.currentMember,
                           resultSelector: transform)
            .distinctUntilChanged()
    }
}


private extension Member {
    
    static func compareNameAndIcon(_ lhs: Self, _ rhs: Self) -> Bool {
        return lhs.nickName == rhs.nickName && lhs.icon == rhs.icon
    }
}
