//
//  SharedMemberListViewModel.swift
//  DiscoveryScene
//
//  Created sudo.park on 2022/01/01.
//  Copyright © 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay
import Prelude
import Optics

import Domain
import CommonPresenting


public struct SharedMemberCellViewModel: Equatable {
    
    public struct Attribute: Equatable {
        let name: String
        let thumbnail: MemberThumbnail
        let description: String?
        
        init(member: Member) {
            self.name = member.nickName ?? "No nickname".localized
            self.thumbnail = member.icon ?? Member.memberDefaultEmoji
            self.description = member.introduction
        }
    }
    
    let memberID: String
}


// MARK: - SharedMemberListViewModel

public protocol SharedMemberListViewModel: AnyObject {

    // interactor
    func refresh()
    func loadMore()
    func excludeMember(_ memberID: String)
    func showMemberProfile(_ memberID: String)
    
    // presenter
    var cellViewModel: Observable<[SharedMemberCellViewModel]> { get }
    func memberAttribute(for memberID: String) -> Observable<SharedMemberCellViewModel.Attribute>
}


// MARK: - SharedMemberListViewModelImple

public final class SharedMemberListViewModelImple: SharedMemberListViewModel {
    
    private let sharedCollection: SharedReadCollection
    private let memberUsecase: MemberUsecase
    private let shareReadCollectionUsecase: ShareReadCollectionUsecase
    private let router: SharedMemberListRouting
    private weak var listener: SharedMemberListSceneListenable?
    
    public init(sharedCollection: SharedReadCollection,
                memberIDs: [String],
                memberUsecase: MemberUsecase,
                shareReadCollectionUsecase: ShareReadCollectionUsecase,
                router: SharedMemberListRouting,
                listener: SharedMemberListSceneListenable?) {
        
        self.sharedCollection = sharedCollection
        self.memberUsecase = memberUsecase
        self.shareReadCollectionUsecase = shareReadCollectionUsecase
        self.router = router
        self.listener = listener
        
        let paging = PagingCursor(remainIDs: memberIDs, pagingIDs: [])
        self.subjects.pagingIDs.accept(paging)
        
        self.bindMemberMap()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate struct PagingCursor {
        
        private let pagingSize: Int = 20
        
        var remainIDs: [String]
        var pagingIDs: [String]
        
        func nextMoving() -> PagingCursor? {
            guard self.remainIDs.isNotEmpty else { return nil }
            let prefixIDs = self.remainIDs.prefix(self.pagingSize)
            return self
                |> \.remainIDs .~ Array(self.remainIDs[prefixIDs.count...])
                |> \.pagingIDs .~ (self.pagingIDs + prefixIDs)
        }
    }
    
    fileprivate final class Subjects {
        
        let pagingIDs = BehaviorRelay<PagingCursor?>(value: nil)
        let memberMap = BehaviorRelay<[String: Member]>(value: [:])
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private func bindMemberMap() {
        
        let loadRequireIDs = self.subjects.pagingIDs
            .compactMap { $0?.pagingIDs }
            .filter { $0.isNotEmpty }
        
        let thenPrepareMembers: ([String]) -> Observable<[String: Member]> = { [weak self] memberIDs in
            return self?.memberUsecase.members(for: memberIDs) ?? .empty()
        }
        
        let updateMembers: ([String: Member]) -> Void = { [weak self] memberMap in
            self?.subjects.memberMap.accept(memberMap)
        }
        
        loadRequireIDs
            .flatMap(thenPrepareMembers)
            .subscribe(onNext: updateMembers)
            .disposed(by: self.disposeBag)
    }
}


// MARK: - SharedMemberListViewModelImple Interactor

extension SharedMemberListViewModelImple {
 
    public func refresh() {
        self.updatePagingCursorIfPossible()
    }
    
    public func loadMore() {
        self.updatePagingCursorIfPossible()
    }
    
    private func updatePagingCursorIfPossible() {
        guard let newPagingIDs = self.subjects.pagingIDs.value?.nextMoving()
        else {
            return
        }
        self.subjects.pagingIDs.accept(newPagingIDs)
    }
    
    public func excludeMember(_ memberID: String) {
        
        let confirmExclude: () -> Void = { [weak self] in
            self?.excludeAndUpdateList(memberID)
        }
     
        let form = AlertForm()
            |> \.title .~ pure("Stop sharing".localized)
            |> \.message .~ pure("Are you sure want to exclude that user from accessing this shared reading list any more?".localized)
            |> \.confirmed .~ pure(confirmExclude)
        self.router.alertForConfirm(form)
    }
    
    public func showMemberProfile(_ memberID: String) {
        self.router.showMemberProfile(memberID)
    }
    
    private func excludeAndUpdateList(_ memberID: String) {
        
        let updateList: () -> Void = { [weak self] in
            guard let paging = self?.subjects.pagingIDs.value else { return }
            let newPaging = paging |> \.pagingIDs %~ { $0.filter { $0 != memberID } }
            self?.subjects.pagingIDs.accept(newPaging)
            self?.listener?.sharedMemberListDidExcludeMember(memberID)
        }
        let handleError: (Error) -> Void = { [weak self] error in
            self?.router.alertError(error)
        }
        self.shareReadCollectionUsecase
            .excludeCollectionSharing(self.sharedCollection.shareID, for: memberID)
            .subscribe(onSuccess: updateList, onError: handleError)
            .disposed(by: self.disposeBag)
    }
}


// MARK: - SharedMemberListViewModelImple Presenter

extension SharedMemberListViewModelImple {
    
    public var cellViewModel: Observable<[SharedMemberCellViewModel]> {
        
        let asCellViewModels: (PagingCursor) -> [SharedMemberCellViewModel]
        asCellViewModels = { cursor in
            return cursor.pagingIDs.map { SharedMemberCellViewModel(memberID: $0) }
        }
        
        return self.subjects.pagingIDs
            .compactMap { $0 }
            .map(asCellViewModels)
            .distinctUntilChanged()
    }
    
    public func memberAttribute(for memberID: String) -> Observable<SharedMemberCellViewModel.Attribute> {
        
        let excludeTargetMemberAttribute: ([String: Member]) -> SharedMemberCellViewModel.Attribute?
        excludeTargetMemberAttribute = { memberMap in
            return memberMap[memberID].map { SharedMemberCellViewModel.Attribute(member: $0) }
        }
        
        return self.subjects.memberMap
            .compactMap(excludeTargetMemberAttribute)
            .distinctUntilChanged()
    }
}
