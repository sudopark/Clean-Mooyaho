//
//  EditReadCollectionViewModel.swift
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


// MARK: - EditReadCollectionViewModel

public protocol EditReadCollectionViewModel: AnyObject {

    // interactor
    func closeScene()
    func enterName(_ name: String)
    func enterDescription(_ description: String)
    func addPriority()
    func addCategory()
    func addRemind()
    func confirmUpdate()
    
    // presenter
    var priority: Observable<ReadPriority?> { get }
    var categories: Observable<[ItemCategory]> { get }
    var remindTime: Observable<TimeStamp?> { get }
    var isProcessing: Observable<Bool> { get }
    var isConfirmable: Observable<Bool> { get }
    var editCaseCollectionValue: ReadCollection? { get }
}


// MARK: - EditReadCollectionViewModelImple

public final class EditReadCollectionViewModelImple: EditReadCollectionViewModel {
    
    private let parentID: String?
    private let editCase: EditCollectionCase
    private let updateUsecase: ReadItemUpdateUsecase
    private let remindUsecase: ReadRemindUsecase
    private let categoriesUsecase: ReadItemCategoryUsecase
    private let router: EditReadCollectionRouting
    private weak var listener: EditReadCollectionSceneListenable?
    
    public init(parentID: String?,
                editCase: EditCollectionCase,
                updateUsecase: ReadItemUpdateUsecase,
                remindUsecase: ReadRemindUsecase,
                categoriesUsecase: ReadItemCategoryUsecase,
                router: EditReadCollectionRouting,
                listener: EditReadCollectionSceneListenable?) {
        
        self.parentID = parentID
        self.editCase = editCase
        self.updateUsecase = updateUsecase
        self.remindUsecase = remindUsecase
        self.categoriesUsecase = categoriesUsecase
        self.router = router
        self.listener =  listener
        
        self.setupPreviousSelectedAttributesIfNeed()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
        let collectionName = BehaviorRelay<String?>(value: nil)
        let description = BehaviorRelay<String?>(value: nil)
        let isProcessing = BehaviorRelay<Bool>(value: false)
        let selectedPriority = BehaviorRelay<ReadPriority?>(value: nil)
        let selectedCategories = BehaviorRelay<[ItemCategory]>(value: [])
        let selectedRemindTime = BehaviorRelay<TimeStamp?>(value: nil)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private func setupPreviousSelectedAttributesIfNeed() {
        guard case let .edit(collection) = self.editCase else { return }
        self.subjects.collectionName.accept(collection.name)
        self.subjects.description.accept(collection.collectionDescription)
        self.subjects.selectedPriority.accept(collection.priority)
        self.subjects.selectedRemindTime.accept(collection.remindTime)
        
        self.categoriesUsecase.categories(for: collection.categoryIDs)
            .take(1)
            .subscribe(onNext: { [weak self] categories in
                self?.subjects.selectedCategories.accept(categories)
            })
            .disposed(by: self.disposeBag)
    }
}


// MARK: - EditReadCollectionViewModelImple Interactor

extension EditReadCollectionViewModelImple {
    
    public func closeScene() {
        self.router.closeScene(animated: true, completed: nil)
    }
    
    public func enterName(_ name: String) {
        self.subjects.collectionName.accept(name)
    }
    
    public func enterDescription(_ description: String) {
        self.subjects.description.accept(description)
    }
    
    public func confirmUpdate() {
        
        guard self.subjects.isProcessing.value == false else { return }
        
        let handleUpdated: (ReadCollection) -> Void = { [weak self] collection in
            self?.subjects.isProcessing.accept(false)
            self?.closeAfterCollectionUpdated(collection)
        }
        
        let handleError: (Error) -> Void = { [weak self] error in
            self?.subjects.isProcessing.accept(false)
            self?.router.alertError(error)
        }
        
        let updatingAction: Maybe<ReadCollection> = {
            switch self.editCase {
            case .makeNew:
                guard let name = self.subjects.collectionName.value else { return .empty() }
                let newCollection = ReadCollection(name: name)
                return self.updateCollection(newCollection)
                
            case let .edit(collection):
                let newCollection = collection
                    |> \.name .~ (self.subjects.collectionName.value ?? collection.name)
                return self.updateCollection(newCollection)
            }
        }()
        
        self.subjects.isProcessing.accept(true)
        
        updatingAction
            .flatMap(updateRemindIfNeed())
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: handleUpdated, onError: handleError)
            .disposed(by: self.disposeBag)
    }
    
    private func updateRemindIfNeed() -> (ReadCollection) -> Maybe<ReadCollection> {
        return { [weak self] newItem in
            guard let self = self else { return .empty() }
            let (oldRemind, newRemind) = (self.editCase.item?.remindTime, newItem.remindTime)
            guard oldRemind != newRemind else { return .just(newItem) }
            let remindUpdating: Maybe<Void> = newRemind
                .map { self.remindUsecase.scheduleRemindMessage(for: newItem, at: $0) }
                ?? self.remindUsecase.cancelRemindMessage(newItem)
            return remindUpdating.catchAndReturn(())
                .map { newItem }
        }
    }
    
    private func updateCollection(_ collection: ReadCollection) -> Maybe<ReadCollection> {
        let newCollection = collection
            |> \.collectionDescription .~ self.subjects.description.value
            |> \.parentID .~ self.parentID
            |> \.priority .~ self.subjects.selectedPriority.value
            |> \.categoryIDs .~ self.subjects.selectedCategories.value.map { $0.uid }
            |> \.remindTime .~ self.subjects.selectedRemindTime.value
        return updateUsecase.updateCollection(newCollection)
            .map{ newCollection }
    }
    
    private func closeAfterCollectionUpdated(_ newCollection: ReadCollection) {
        
        self.router.closeScene(animated: true) { [weak self] in
            self?.listener?.editReadCollection(didChange: newCollection)
        }
    }
}


// MARK: - EditReadCollectionViewModelImple Interactor + edit priority

extension EditReadCollectionViewModelImple {
 
    public func addPriority() {
        
        let previousSelectedValue = self.subjects.selectedPriority.value
        self.router.selectPriority(startWith: previousSelectedValue)
    }
    
    public func editReadPriority(didSelect priority: ReadPriority) {
        
        self.subjects.selectedPriority.accept(priority)
    }
}


// MARK: - EditReadCollectionViewModelImple Interactor + edit categories

extension EditReadCollectionViewModelImple {
    
    public func addCategory() {
        
        let previousSelected = self.subjects.selectedCategories.value
        self.router.selectCategories(startWith: previousSelected)
    }
    
    public func editCategory(didSelect categories: [ItemCategory]) {
        self.subjects.selectedCategories.accept(categories)
    }
}


// MARK: - EditReadCollectionViewModelImple Interactor + edit remind

extension EditReadCollectionViewModelImple {
    
    public func addRemind() {
        
        let previousSelected = self.subjects.selectedRemindTime.value
        self.router.updateRemind(.select(startWith: previousSelected))
    }
    
    public func editReadRemind(didSelect time: Date?) {
        self.subjects.selectedRemindTime.accept(time?.timeIntervalSince1970)
    }
}


// MARK: - EditReadCollectionViewModelImple Presenter

extension EditReadCollectionViewModelImple {
    
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
    
    public var isConfirmable: Observable<Bool> {
        return self.subjects.collectionName
            .map { $0?.isNotEmpty == true }
            .distinctUntilChanged()
    }
    
    public var isProcessing: Observable<Bool> {
        return self.subjects.isProcessing
            .distinctUntilChanged()
    }
    
    public var editCaseCollectionValue: ReadCollection? {
        guard case let .edit(collection) = self.editCase else { return nil }
        return collection
    }
}


private extension EditCollectionCase {
    
    var item: ReadCollection? {
        guard case let .edit(collection) = self else { return nil }
        return collection
    }
}
