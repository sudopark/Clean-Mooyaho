//
//  SharedCollectionInfoDialogViewModel.swift
//  DiscoveryScene
//
//  Created sudo.park on 2021/11/20.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - SharedCollectionInfoDialogViewModel

public protocol SharedCollectionInfoDialogViewModel: AnyObject {

    // interactor
    func removeFromSharedList()
    func requestClose()
    
    // presenter
    var collectionTitle: Observable<String> { get }
    var isRemoving: Observable<Bool> { get }
}


// MARK: - SharedCollectionInfoDialogViewModelImple

public final class SharedCollectionInfoDialogViewModelImple: SharedCollectionInfoDialogViewModel {
    
    private let collection: SharedReadCollection
    private let shareItemsUsecase: SharedReadCollectionLoadUsecase
    private let router: SharedCollectionInfoDialogRouting
    private weak var listener: SharedCollectionInfoDialogSceneListenable?
    
    public init(collection: SharedReadCollection,
                shareItemsUsecase: SharedReadCollectionLoadUsecase,
                router: SharedCollectionInfoDialogRouting,
                listener: SharedCollectionInfoDialogSceneListenable?) {
        self.collection = collection
        self.shareItemsUsecase = shareItemsUsecase
        self.router = router
        self.listener = listener
        
        self.subjects.collection.accept(collection)
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
        
        let isRemoving = BehaviorRelay<Bool>(value: false)
        let collection = BehaviorRelay<SharedReadCollection?>(value: nil)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - SharedCollectionInfoDialogViewModelImple Interactor

extension SharedCollectionInfoDialogViewModelImple {
    
    public func removeFromSharedList() {
        
        guard self.subjects.isRemoving.value == false,
              let collection = self.subjects.collection.value else { return }
        
        let confirmed: () -> Void = { [weak self] in
            self?.removeFromList(shareID: collection.shareID)
        }

        guard let form = AlertBuilder(base: .init())
                .title("Remove".localized)
                .message("tbd".localized)
                .confirmed(confirmed)
                .build()
        else {
            return
        }
        self.router.alertForConfirm(form)
    }
    
    private func removeFromList(shareID: String) {
        let itemRemoved: () -> Void = { [weak self] in
            self?.subjects.isRemoving.accept(false)
            self?.closeAndNotifyItemRemoved(shareID)
        }
        
        let handleError: (Error) -> Void = { [weak self] error in
            self?.subjects.isRemoving.accept(false)
            self?.router.alertError(error)
        }
        
        self.subjects.isRemoving.accept(true)
        self.shareItemsUsecase.removeFromSharedList(shareID: shareID)
            .subscribe(onSuccess: itemRemoved, onError: handleError)
            .disposed(by: self.disposeBag)
    }
    
    private func closeAndNotifyItemRemoved(_ sharedID: String) {
        self.router.closeScene(animated: true) { [weak self] in
            self?.listener?.sharedCollectionDidRemoved(sharedID)
        }
    }
    
    public func requestClose() {
        guard self.subjects.isRemoving.value == false else { return }
        self.router.closeScene(animated: true, completed: nil)
    }
}


// MARK: - SharedCollectionInfoDialogViewModelImple Presenter

extension SharedCollectionInfoDialogViewModelImple {
    
    public var collectionTitle: Observable<String> {
        return self.subjects.collection
            .compactMap { $0?.name }
    }
    
    public var isRemoving: Observable<Bool> {
        return self.subjects.isRemoving
            .distinctUntilChanged()
    }
}
