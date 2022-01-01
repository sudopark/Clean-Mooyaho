//
//  StopShareCollectionViewModel.swift
//  DiscoveryScene
//
//  Created sudo.park on 2021/11/16.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - StopShareCollectionViewModel

public protocol StopShareCollectionViewModel: AnyObject {

    // interactor
    func refresh()
    func findWhoSharedThieList()
    func openShare()
    func requestStopShare()
    
    // presenter
    var sharedMemberCount: Observable<Int> { get }
    var isStopSharing: Observable<Bool> { get }
    var collectionTitle: Observable<String> { get }
}


// MARK: - StopShareCollectionViewModelImple

public final class StopShareCollectionViewModelImple: StopShareCollectionViewModel {
    
    private let shareURLScheme: String
    private let collectionID: String
    private let shareCollectionUsecase: ShareReadCollectionUsecase & SharedReadCollectionLoadUsecase
    private let router: StopShareCollectionRouting
    private weak var listener: StopShareCollectionSceneListenable?
    
    public init(shareURLScheme: String,
                collectionID: String,
                shareCollectionUsecase: ShareReadCollectionUsecase & SharedReadCollectionLoadUsecase,
                router: StopShareCollectionRouting,
                listener: StopShareCollectionSceneListenable?) {
        self.shareURLScheme = shareURLScheme
        self.collectionID = collectionID
        self.shareCollectionUsecase = shareCollectionUsecase
        self.router = router
        self.listener = listener
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
        let collection = BehaviorRelay<SharedReadCollection?>(value: nil)
        let isStopSharing = BehaviorRelay<Bool>(value: false)
        let sharedMemberIDs = BehaviorRelay<[String]?>(value: nil)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - StopShareCollectionViewModelImple Interactor

extension StopShareCollectionViewModelImple {
    
    public func refresh() {
        
        let refreshCollection: (SharedReadCollection) -> Void = { [weak self] collection in
            self?.subjects.collection.accept(collection)
            self?.refreshSharedMemberIDs(collection.shareID)
        }
        self.shareCollectionUsecase.loadMyharingCollection(for: self.collectionID)
            .subscribe(onNext: refreshCollection, onError: self.alertError())
            .disposed(by: self.disposeBag)
    }
    
    private func refreshSharedMemberIDs(_ shareID: String) {
        let refreshSharedMemberIDs: ([String]) -> Void = { [weak self] ids in
            self?.subjects.sharedMemberIDs.accept(ids)
        }
        
        self.shareCollectionUsecase.loadSharedMemberIDs(of: shareID)
            .subscribe(onSuccess: refreshSharedMemberIDs)
            .disposed(by: self.disposeBag)
    }
    
    public func findWhoSharedThieList() {
        guard let collection = self.subjects.collection.value,
              let memberIDs = self.subjects.sharedMemberIDs.value, memberIDs.isNotEmpty
        else { return }
        self.router.findWhoSharedReadCollection(collection, memberIDs: memberIDs)
    }
    
    public func openShare() {
        guard let collection = self.subjects.collection.value else { return }
        let url = "\(self.shareURLScheme)://\(collection.fullSharePath)"
        self.router.presentShareSheet(with: url)
    }
    
    public func requestStopShare() {
        
        guard self.subjects.isStopSharing.value == false else { return }
        
        let stopConfirmed: () -> Void = { [weak self] in
            self?.stopSharing()
        }
        
        guard let form = AlertBuilder(base: .init())
                .title("Stop sharing".localized)
                .message("Do you want to stop sharing? (Users who have shared the reading list will no longer be able to view it.)".localized)
            .confirmed(stopConfirmed).build() else { return }
        
        self.router.alertForConfirm(form)
    }
    
    private func stopSharing() {
        
        self.subjects.isStopSharing.accept(true)
        
        let shareStopped: () -> Void = { [weak self] in
            self?.router.showToast("Sharing stopped.".localized)
            self?.router.closeScene(animated: true, completed: nil)
        }
        
        self.shareCollectionUsecase
            .stopShare(collection: self.collectionID)
            .subscribe(onSuccess: shareStopped, onError: self.alertError(shouldToggleSharing: true))
            .disposed(by: self.disposeBag)
    }
    
    private func alertError(shouldToggleSharing: Bool = false) -> (Error) -> Void {
        return { [weak self] error in
            if shouldToggleSharing {
                self?.subjects.isStopSharing.accept(false)
            }
            self?.router.alertError(error)
        }
    }
}


// MARK: - StopShareCollectionViewModelImple Presenter

extension StopShareCollectionViewModelImple {
    
    public var sharedMemberCount: Observable<Int> {
        return self.subjects.sharedMemberIDs
            .compactMap { $0?.count }
            .distinctUntilChanged()
    }
    
    public var collectionTitle: Observable<String> {
        return self.subjects.collection
            .compactMap { $0?.name }
            .distinctUntilChanged()
    }
    
    public var isStopSharing: Observable<Bool> {
        return self.subjects.isStopSharing
            .distinctUntilChanged()
    }
}
