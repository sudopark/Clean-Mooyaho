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
    func confirmUpdate()
    
    // presenter
    var priority: Observable<ReadPriority?> { get }
    var categories: Observable<[ItemCategory]> { get }
    var isProcessing: Observable<Bool> { get }
    var isConfirmable: Observable<Bool> { get }
}


// MARK: - EditReadCollectionViewModelImple

public final class EditReadCollectionViewModelImple: EditReadCollectionViewModel {
    
    private let parentID: String?
    private let editCase: EditCollectionCase
    private let updateUsecase: ReadItemUpdateUsecase
    private let router: EditReadCollectionRouting
    private let completed: (ReadCollection) -> Void
    
    public init(parentID: String?,
                editCase: EditCollectionCase,
                updateUsecase: ReadItemUpdateUsecase,
                router: EditReadCollectionRouting,
                completed: @escaping (ReadCollection) -> Void) {
        
        self.parentID = parentID
        self.editCase = editCase
        self.updateUsecase = updateUsecase
        self.router = router
        self.completed =  completed
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
        let collectionName = BehaviorRelay<String?>(value: nil)
        let description = BehaviorRelay<String?>(value: nil)
        let isProcessing = BehaviorRelay<Bool>(value: false)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
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
    
    public func addPriority() {
        
    }
    
    public func addCategory() {
        
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
            case .makeNew: return self.makeNewColletion()
            case .edit: return .empty()
            }
        }()
        
        self.subjects.isProcessing.accept(true)
        
        updatingAction
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: handleUpdated, onError: handleError)
            .disposed(by: self.disposeBag)
    }
    
    private func makeNewColletion() -> Maybe<ReadCollection> {
        guard let name = self.subjects.collectionName.value else { return .empty() }
        let newCollection = ReadCollection(name: name)
            |> \.collectionDescription .~ self.subjects.description.value
            |> \.parentID .~ self.parentID
        return updateUsecase.updateCollection(newCollection)
            .map{ newCollection }
    }
    
    private func closeAfterCollectionUpdated(_ newCollection: ReadCollection) {
        
        self.router.closeScene(animated: true) { [weak self] in
            self?.completed(newCollection)
        }
    }
}


// MARK: - EditReadCollectionViewModelImple Presenter

extension EditReadCollectionViewModelImple {
    
    public var priority: Observable<ReadPriority?> { return .empty() }
    
    public var categories: Observable<[ItemCategory]> { .empty() }
    
    public var isConfirmable: Observable<Bool> {
        return self.subjects.collectionName
            .map { $0?.isNotEmpty == true }
            .distinctUntilChanged()
    }
    
    public var isProcessing: Observable<Bool> {
        return self.subjects.isProcessing
            .distinctUntilChanged()
    }
}
