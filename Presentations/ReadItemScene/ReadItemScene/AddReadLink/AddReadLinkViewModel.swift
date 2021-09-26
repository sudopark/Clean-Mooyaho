//
//  AddReadLinkViewModel.swift
//  ReadItemScene
//
//  Created sudo.park on 2021/09/26.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - AddReadLinkViewModel

public enum EnteredLinkPreview {
    case exist(LinkPreview)
    case notExist
    
    public var preview: LinkPreview? {
        guard case let .exist(preview) = self else { return nil }
        return preview
    }
}

public protocol AddReadLinkViewModel: AnyObject {

    // interactor
    func enterURL(_ url: String)
    func enterURLFinished()
    func saveLink()
    
    // presenter
    var isConfirmable: Observable<Bool> { get }
    var isLoadingPreview: Observable<Bool> { get }
    var enteredLinkPreview: Observable<EnteredLinkPreview> { get }
    var isSavingLinkItem: Observable<Bool> { get }
}


// MARK: - AddReadLinkViewModelImple

public final class AddReadLinkViewModelImple: AddReadLinkViewModel {
    
    private let collectionID: String?
    private let readItemUsecase: ReadItemUsecase
    private let router: AddReadLinkRouting
    private let itemAddedCallback: (() -> Void)?
    
    public init(collectionID: String?,
                readItemUsecase: ReadItemUsecase,
                router: AddReadLinkRouting,
                itemAddded: (() -> Void)? = nil) {
        self.collectionID = collectionID
        self.readItemUsecase = readItemUsecase
        self.router = router
        self.itemAddedCallback = itemAddded
        
        self.internalBinding()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
        let isLoadingPreview = PublishSubject<Bool>()
        let loadPreview = PublishSubject<Void>()
        let preview = PublishSubject<LinkPreview?>()
        let enteredURL = BehaviorRelay<String>(value: "")
        let isSavingLinkItem = PublishSubject<Bool>()
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    
    private func internalBinding() {
        
        let startLoadWithValidURL = self.subjects.loadPreview
            .withLatestFrom(self.validEnteredURL)
            .compactMap{ $0 }

        let loadPreviewWithoutError: (String) -> Observable<LinkPreview?> = { [weak self] url in
            guard let self = self else { return .empty() }
            
            self.subjects.isLoadingPreview.onNext(true)
            return self.readItemUsecase.loadLinkPreview(url)
                .mapAsOptional()
                .catchAndReturn(nil)
        }
        
        let previewLoadedOrNot: (LinkPreview?) -> Void = { preview in
            self.subjects.isLoadingPreview.onNext(false)
            self.subjects.preview.onNext(preview)
        }
        
        startLoadWithValidURL
            .flatMapLatest(loadPreviewWithoutError)
            .subscribe(onNext: previewLoadedOrNot)
            .disposed(by: self.disposeBag)
    }
}


// MARK: - AddReadLinkViewModelImple Interactor

extension AddReadLinkViewModelImple {
    
    
    public func enterURL(_ url: String) {
        self.subjects.enteredURL.accept(url)
    }
    
    public func enterURLFinished() {
        self.subjects.loadPreview.onNext()
    }
    
    public func saveLink() {
        
        let linkItemAdded: () -> Void = { [weak self] in
            self?.subjects.isSavingLinkItem.onNext(false)
            self?.closeWithSignal()
        }
        let handleError: (Error) -> Void = { [weak self] error in
            self?.subjects.isSavingLinkItem.onNext(false)
            self?.router.alertError(error)
        }
        
        self.subjects.isSavingLinkItem.onNext(true)
        
        let url = self.subjects.enteredURL.value
        self.readItemUsecase.saveLink(url, at: self.collectionID)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: linkItemAdded, onError: handleError)
            .disposed(by: self.disposeBag)
    }
    
    private func closeWithSignal() {
        self.router.closeScene(animated: true) { [weak self] in
            self?.itemAddedCallback?()
        }
    }
}


// MARK: - AddReadLinkViewModelImple Presenter

extension AddReadLinkViewModelImple {
    
    public var isLoadingPreview: Observable<Bool> {
        return self.subjects.isLoadingPreview
            .distinctUntilChanged()
    }
    
    public var enteredLinkPreview: Observable<EnteredLinkPreview> {
        
        let asEnteredLinkPreview: (LinkPreview?) -> EnteredLinkPreview = { preview in
            guard let preview = preview else {
                return .notExist
            }
            return .exist(preview)
        }
        
        return self.subjects.preview
            .map(asEnteredLinkPreview)
    }
    
    private var validEnteredURL: Observable<String?> {
        return self.subjects.enteredURL
            .map{ $0.isURLAddress ? $0 : nil }
    }
    
    public var isConfirmable: Observable<Bool> {
        return self.validEnteredURL
            .map{ $0 != nil }
            .distinctUntilChanged()
    }
    
    public var isSavingLinkItem: Observable<Bool> {
        return self.subjects.isSavingLinkItem
            .distinctUntilChanged()
    }
}
