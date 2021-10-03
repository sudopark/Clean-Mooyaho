//
//  EditLinkItemViewModel.swift
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/03.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


public enum LoadPreviewStatus: Equatable {
    case loading
    case loaded(url: String, preview: LinkPreview)
    case loadFail(url: String)
}


// MARK: - EditLinkItemViewModel

public protocol EditLinkItemViewModel: AnyObject {

    // interactor
    func preparePreview()
    func enterCustomName(_ name: String)
    func confirmSave()
    func editPriority()
    func editCategory()
    func rewind()
    
    // presenter
    var itemSuggestedTitle: Observable<String> { get }
    var priority: Observable<ReadPriority?> { get }
    var categories: Observable<[ItemCategory]> { get }
    var linkPreviewStatus: Observable<LoadPreviewStatus> { get }
    var isProcessing: Observable<Bool> { get }
}


// MARK: - EditLinkItemViewModelImple

public final class EditLinkItemViewModelImple: EditLinkItemViewModel {
    
    private let collectionID: String?
    private let editCase: EditLinkItemCase
    private let readUsecase: ReadItemUsecase
    private let router: EditLinkItemRouting
    private let completed: (ReadLink) -> Void
    
    public init(collectionID: String?,
                editCase: EditLinkItemCase,
                readUsecase: ReadItemUsecase,
                router: EditLinkItemRouting,
                completed: @escaping (ReadLink) -> Void) {
        self.collectionID = collectionID
        self.editCase = editCase
        self.readUsecase = readUsecase
        self.router = router
        self.completed = completed
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
        let previewLoadStatus = PublishSubject<LoadPreviewStatus>()
        let customName = BehaviorRelay<String?>(value: nil)
        let isProcessing = BehaviorRelay<Bool>(value: false)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - EditLinkItemViewModelImple Interactor

extension EditLinkItemViewModelImple {
 
    public func preparePreview() {
        
        let url = self.editCase.url
        
        let previewLoaded: (LinkPreview) -> Void = { [weak self] preview in
            self?.subjects.previewLoadStatus.onNext(.loaded(url: url, preview: preview))
        }
        let handleError: (Error) -> Void = { [weak self] error in
            self?.subjects.previewLoadStatus.onNext(.loadFail(url: url))
        }
        
        self.subjects.previewLoadStatus.onNext(.loading)
        self.readUsecase.loadLinkPreview(url)
            .subscribe(onNext: previewLoaded, onError: handleError)
            .disposed(by: self.disposeBag)
    }
    
    public func enterCustomName(_ name: String) {
        self.subjects.customName.accept(name)
    }
    
    public func confirmSave() {
        
        let newItem = self.prepareNewLinkItem()
        
        let completed: () -> Void = { [weak self] in
            self?.subjects.isProcessing.accept(false)
            self?.closeSceneAfterUpdateItem(newItem)
        }
        let handleError: (Error) -> Void = { [weak self] error in
            self?.subjects.isProcessing.accept(false)
            self?.router.alertError(error)
        }
        
        self.subjects.isProcessing.accept(true)
        self.readUsecase.saveLink(newItem, at: self.collectionID)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: completed, onError: handleError)
            .disposed(by: self.disposeBag)
    }
    
    private func closeSceneAfterUpdateItem(_ item: ReadLink) {
        self.router.closeScene(animated: true) { [weak self] in
            self?.completed(item)
        }
    }
    
    private func prepareNewLinkItem() -> ReadLink {
        switch self.editCase {
        case let .makeNew(url):
            return ReadLink(link: url)
            
        case let .edit(item):
            return item
        }
    }
    
    public func editPriority() {
        logger.todoImplement()
    }
    
    public func editCategory() {
        logger.todoImplement()
    }
    
    public func rewind() {
        logger.todoImplement()
    }
}


// MARK: - EditLinkItemViewModelImple Presenter

extension EditLinkItemViewModelImple {
    
    public var itemSuggestedTitle: Observable<String> {
        
        let getTitleInfo: (LoadPreviewStatus) -> String? = { status in
            guard case let .loaded(_, preview) = status else { return nil }
            return preview.title
        }
        
        let ignoreWhenUserEnterSomething: (String?, String?) -> String? = { itemTitle, customName in
            return customName?.isNotEmpty == true ? nil : itemTitle
        }
        
        return self.subjects.previewLoadStatus
            .compactMap(getTitleInfo)
            .withLatestFrom(self.subjects.customName, resultSelector: ignoreWhenUserEnterSomething)
            .compactMap{ $0 }
    }
    
    public var linkPreviewStatus: Observable<LoadPreviewStatus> {
        
        let regardInsufficientPreviewAsFailure: (LoadPreviewStatus) -> LoadPreviewStatus
        regardInsufficientPreviewAsFailure = { status in
            guard case let .loaded(url, preview) = status else { return status }
            return preview.isEmpty ? .loadFail(url: url) : status
        }
        
        return self.subjects.previewLoadStatus
            .map(regardInsufficientPreviewAsFailure)
            .distinctUntilChanged()
    }
    
    public var priority: Observable<ReadPriority?> {
        return .empty()
    }
    
    public var categories: Observable<[ItemCategory]> {
        return .empty()
    }
    
    public var isProcessing: Observable<Bool> {
        return self.subjects.isProcessing
            .distinctUntilChanged()
    }
}

private extension EditLinkItemCase {
    
    var url: String {
        switch self {
        case let .makeNew(url): return url
        case let .edit(item): return item.link
        }
    }
}

private extension LinkPreview {
    
    var isEmpty: Bool {
        return (self.title?.isNotEmpty == true && self.description?.isNotEmpty == true) == false
    }
}
