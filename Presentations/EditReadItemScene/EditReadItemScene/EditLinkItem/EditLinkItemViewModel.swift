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
import Prelude
import Optics

import Domain
import CommonPresenting
import Extensions


public enum LoadPreviewStatus: Equatable {
    case loading
    case loaded(url: String, preview: LinkPreview)
    case loadFail(url: String)
}

enum ParentCollection {
    case root
    case some(ReadCollection)
    
    init(_ collection: ReadCollection?) {
        switch collection {
        case .none: self = .root
        case let .some(value): self = .some(value)
        }
    }
    
    var collection: ReadCollection? {
        guard case let .some(collection) = self else { return nil }
        return collection
    }
    
    var collectionName: String {
        switch self {
        case .root: return "My Read Collections".localized
        case let .some(collection): return collection.name
        }
    }
}


// MARK: - EditLinkItemViewModel

public protocol EditLinkItemViewModel: AnyObject, Sendable {

    // interactor
    func preparePreview()
    func enterCustomName(_ name: String)
    func confirmSave()
    func editPriority()
    func editCategory()
    func editRemind()
    func rewind()
    func changeCollection()
    func notifyDidDismissed()
    
    // presenter
    var itemSuggestedTitle: Observable<String> { get }
    var priority: Observable<ReadPriority?> { get }
    var categories: Observable<[ItemCategory]> { get }
    var remindTime: Observable<TimeStamp?> { get }
    var linkPreviewStatus: Observable<LoadPreviewStatus> { get }
    var isProcessing: Observable<Bool> { get }
    var editcaseReadLink: ReadLink? { get }
    var isConfirmable: Observable<Bool> { get }
    var selectedParentCollectionName: Observable<String> { get }
    var hidePullGuideView: Bool { get }
}


// MARK: - EditLinkItemViewModelImple

public final class EditLinkItemViewModelImple: EditLinkItemViewModel, @unchecked Sendable {
    
    private let collectionID: String?
    private let editCase: EditLinkItemCase
    private let readUsecase: ReadItemUsecase
    private let remindUsecase: ReadRemindUsecase
    private let categoryUsecase: ReadItemCategoryUsecase
    private let router: EditLinkItemRouting
    private weak var listener: EditLinkItemSceneListenable?
    
    public init(collectionID: String?,
                editCase: EditLinkItemCase,
                readUsecase: ReadItemUsecase,
                remindUsecase: ReadRemindUsecase,
                categoryUsecase: ReadItemCategoryUsecase,
                router: EditLinkItemRouting,
                listener: EditLinkItemSceneListenable?) {
        self.collectionID = collectionID
        self.editCase = editCase
        self.readUsecase = readUsecase
        self.remindUsecase = remindUsecase
        self.categoryUsecase = categoryUsecase
        self.router = router
        self.listener = listener
        
        self.setupPreviousSelectedPropertiesIfNeed()
        self.setupParentCollection()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects: Sendable {
        let previewLoadStatus = PublishSubject<LoadPreviewStatus>()
        let selectedPriority = BehaviorRelay<ReadPriority?>(value: nil)
        let selectedCategories = BehaviorRelay<[ItemCategory]>(value: [])
        let selectParentCollection = BehaviorRelay<ParentCollection?>(value: nil)
        let customName = BehaviorRelay<String?>(value: nil)
        let selectedRemindTime = BehaviorRelay<TimeStamp?>(value: nil)
        let isProcessing = BehaviorRelay<Bool>(value: false)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private func setupPreviousSelectedPropertiesIfNeed() {
        guard case let .edit(link) = self.editCase else { return }
        self.subjects.customName.accept(link.customName)
        self.subjects.selectedPriority.accept(link.priority)
        self.subjects.selectedRemindTime.accept(link.remindTime)
        
        self.categoryUsecase.categories(for: link.categoryIDs)
            .take(1)
            .subscribe(onNext: { [weak self] categories in
                self?.subjects.selectedCategories.accept(categories)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func setupParentCollection() {
        guard let parentID = self.collectionID
        else {
            self.subjects.selectParentCollection.accept(.root)
            return
        }
        
        self.readUsecase.loadCollectionInfo(parentID)
            .subscribe(onNext: { [weak self] collection in
                self?.subjects.selectParentCollection.accept(.some(collection))
            })
            .disposed(by: self.disposeBag)
    }
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
        
        guard self.subjects.isProcessing.value == false else { return }
        
        let newItem = self.prepareNewLinkItem()
        
        let completed: () -> Void = { [weak self] in
            self?.subjects.isProcessing.accept(false)
            self?.closeSceneAfterUpdateItem(newItem)
        }
        let handleError: (Error) -> Void = { [weak self] error in
            self?.subjects.isProcessing.accept(false)
            self?.router.alertError(error)
        }
        
        let parentCollectionID = newItem.parentID
        
        self.subjects.isProcessing.accept(true)
        self.readUsecase.saveLink(newItem, at: parentCollectionID)
            .flatMap(updateRemindIfNeed(newItem))
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: completed, onError: handleError)
            .disposed(by: self.disposeBag)
    }
    
    private func updateRemindIfNeed(_ newItem: ReadLink) -> () -> Maybe<Void> {
        return { [weak self] in
            guard let self = self else { return .empty() }
            let (oldRemind, newRemind) = (self.editCase.item?.remindTime, newItem.remindTime)
            guard oldRemind != newRemind else { return .just() }
            let updateReminding: Maybe<Void> = newRemind
                .map { self.remindUsecase.scheduleRemindMessage(for: newItem, at: $0) }
                ?? self.remindUsecase.cancelRemindMessage(newItem)
            return updateReminding.catchAndReturn(())
        }
    }
    
    private func closeSceneAfterUpdateItem(_ item: ReadLink) {
        self.router.closeScene(animated: true) { [weak self] in
            self?.listener?.editReadLink(didEdit: item)
        }
    }
    
    private func prepareNewLinkItem() -> ReadLink {
        switch self.editCase {
        case let .makeNew(url):
            return ReadLink(link: url)
                |> \.customName .~ self.subjects.customName.value.flatMap { $0.isEmpty ? nil : $0 }
                |> \.priority .~ self.subjects.selectedPriority.value
                |> \.categoryIDs .~ self.subjects.selectedCategories.value.map { $0.uid }
                |> \.remindTime .~ self.subjects.selectedRemindTime.value
                |> \.parentID .~ self.subjects.selectParentCollection.value?.collection?.uid
            
        case let .edit(item):
            return item
                |> \.customName .~ self.subjects.customName.value.flatMap { $0.isNotEmpty ? $0 : item.customName }
                |> \.priority .~ self.subjects.selectedPriority.value
                |> \.categoryIDs .~ self.subjects.selectedCategories.value.map { $0.uid }
                |> \.remindTime .~ self.subjects.selectedRemindTime.value
                |> \.parentID .~ self.subjects.selectParentCollection.value?.collection?.uid
        }
    }
    
    public func rewind() {
        self.router.requestRewind()
    }
    
    public func notifyDidDismissed() {
        self.listener?.editReadLinkDidDismissed()
    }
}


// MARK: - EditLinkItemViewModelImple Interactor + edit priority

extension EditLinkItemViewModelImple {
    
    public func editPriority() {
        let previousSelected = self.subjects.selectedPriority.value
        self.router.editPriority(startWith: previousSelected)
    }
    
    public func editReadPriority(didSelect priority: ReadPriority) {
        self.subjects.selectedPriority.accept(priority)
    }
}

// MARK: - EditLinkItemViewModelImple Interactor + edit categories

extension EditLinkItemViewModelImple {
    
    public func editCategory() {
        let previousSelected = self.subjects.selectedCategories.value
        self.router.editCategory(startWith: previousSelected)
    }
    
    public func editCategory(didSelect categories: [ItemCategory]) {
        self.subjects.selectedCategories.accept(categories)
    }
}


// MARK: - EditLinkItemViewModelImple Interactor + edit categories

extension EditLinkItemViewModelImple {
    
    public func editRemind() {
        let previousSelected = self.subjects.selectedRemindTime.value
        self.router.editRemind(.select(startWith: previousSelected))
    }
    
    public func editReadRemind(didSelect time: Date?) {
        self.subjects.selectedRemindTime.accept(time?.timeIntervalSince1970)
    }
}


// MARK: - EditLinkItemViewModelImple Interactor + edit parent collection

extension EditLinkItemViewModelImple {
    
    public func changeCollection() {
        
        let currentParent = self.subjects.selectParentCollection.value?.collection
        self.router.editParentCollection(currentParent)
    }
    
    public func navigateCollection(didSelectCollection collection: ReadCollection?) {
        
        let newParentCollection = ParentCollection(collection)
        self.subjects.selectParentCollection.accept(newParentCollection)
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
        return self.subjects.selectedPriority
            .distinctUntilChanged()
    }
    
    public var categories: Observable<[ItemCategory]> {
        return self.subjects.selectedCategories
            .distinctUntilChanged()
    }
    
    public var remindTime: Observable<TimeStamp?> {
        return self.subjects.selectedRemindTime
            .distinctUntilChanged()
    }
    
    public var isProcessing: Observable<Bool> {
        return self.subjects.isProcessing
            .distinctUntilChanged()
    }
    
    public var editcaseReadLink: ReadLink? {
        guard case let .edit(item) = self.editCase else { return nil }
        return item
    }
    
    public var selectedParentCollectionName: Observable<String> {
        
        let transform: (ParentCollection?) -> String? = { parent in
            return parent.map { "parent list: %@".localized(with: $0.collectionName) }
        }
        return self.subjects.selectParentCollection
            .compactMap(transform)
            .distinctUntilChanged()
    }
    
    public var isConfirmable: Observable<Bool> {
        
        return self.subjects.selectParentCollection
            .map { $0 != nil }
            .distinctUntilChanged()
    }
    
    public var hidePullGuideView: Bool {
        guard case .makeNew = self.editCase else { return false }
        return true
    }
}

private extension EditLinkItemCase {
    
    var url: String {
        switch self {
        case let .makeNew(url): return url
        case let .edit(item): return item.link
        }
    }
    
    var parentID: String? {
        guard case let .edit(item) = self else { return nil }
        return item.parentID
    }
    
    var item: ReadLink? {
        guard case let .edit(item) = self else { return nil }
        return item
    }
}

private extension LinkPreview {
    
    var isEmpty: Bool {
        return (self.title?.isNotEmpty == true && self.description?.isNotEmpty == true) == false
    }
}
