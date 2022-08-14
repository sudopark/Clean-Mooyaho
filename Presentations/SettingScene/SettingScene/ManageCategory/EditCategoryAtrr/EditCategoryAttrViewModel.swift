//
//  EditCategoryAttrViewModel.swift
//  SettingScene
//
//  Created sudo.park on 2021/12/04.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay
import Prelude
import Optics

import Domain
import CommonPresenting


// MARK: - EditCategoryAttrViewModel

public protocol EditCategoryAttrViewModel: AnyObject, Sendable {

    // interactor
    func enter(name: String)
    func selectNewColor()
    func delete()
    func confirmSaveChange()
    
    // presenter
    var initialName: String { get }
    var isChangeSavable: Observable<Bool> { get }
    var selectedColorCode: Observable<String> { get }
}


// MARK: - EditCategoryAttrViewModelImple

public final class EditCategoryAttrViewModelImple: EditCategoryAttrViewModel, @unchecked Sendable {
    
    private let category: ItemCategory
    private let categoryUsecase: ReadItemCategoryUsecase
    private let router: EditCategoryAttrRouting
    private weak var listener: EditCategoryAttrSceneListenable?
    
    public init(category: ItemCategory,
                categoryUsecase: ReadItemCategoryUsecase,
                router: EditCategoryAttrRouting,
                listener: EditCategoryAttrSceneListenable?) {
        
        self.category = category
        self.categoryUsecase = categoryUsecase
        self.router = router
        self.listener = listener
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects: Sendable {
        
        let pendingNewName = BehaviorRelay<String?>(value: nil)
        let pendingNewColorCode = BehaviorRelay<String?>(value: nil)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - EditCategoryAttrViewModelImple Interactor

extension EditCategoryAttrViewModelImple {
 
    public func enter(name: String) {
        self.subjects.pendingNewName.accept(name)
    }
    
    public func selectNewColor() {
        let currentColor = self.category.colorCode
        self.router.selectNewColor(currentColor)
    }
    
    public func colorSelect(didSeelctColor hexCode: String) {
        self.subjects.pendingNewColorCode.accept(hexCode)
    }
    
    public func delete() {
        
        let confirmed: () -> Void = { [weak self] in
            self?.deleteCategoryAfterConfirm()
        }
        guard let form = AlertBuilder(base: .init())
                .title("Delete category".localized)
                .message("Are you sure you want to delete this category?".localized)
                .confirmed(confirmed)
                .build()
        else {
            return
        }
        self.router.alertForConfirm(form)
    }
    
    private func deleteCategoryAfterConfirm() {
        
        let category = self.category
        let deleted: () -> Void = { [weak self] in
            self?.listener?.editCategory(didDeleted: category.uid)
            self?.router.closeScene(animated: true, completed: nil)
        }
        let hanleError: (Error) -> Void = { [weak self] error in
            self?.router.alertError(error)
        }
        
        self.categoryUsecase.deleteCategory(category.uid)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: deleted,
                       onError: hanleError)
            .disposed(by: self.disposeBag)
    }
    
    public func confirmSaveChange() {
        
        let params = self.updateCategoryParams()
        
        let saved: (ItemCategory) -> Void = { [weak self] newCategory in
            guard let self = self else { return }
            self.listener?.editCategory(didChaged: newCategory)
            self.router.closeScene(animated: true, completed: nil)
        }
        
        let handleError: (Error) -> Void = { [weak self] error in
            error is SameNameCategoryExistsError
            ? self?.router.alertNameDuplicated(params.newName ?? "")
                : self?.router.alertError(error)
        }
        
        self.categoryUsecase.updateCategory(by: params, from: self.category)
            .subscribe(onSuccess: saved,
                       onError: handleError)
            .disposed(by: self.disposeBag)
    }
    
    private func updateCategoryParams() -> UpdateCategoryAttrParams {
        
        let (oldName, pendingName) = (self.category.name, self.subjects.pendingNewName.value)
        let newName = pendingName != nil && oldName != pendingName ? pendingName : nil
        return UpdateCategoryAttrParams(uid: self.category.uid)
            |> \.newName .~ newName
            |> \.newColorCode .~ self.subjects.pendingNewColorCode.value
    }
}


// MARK: - EditCategoryAttrViewModelImple Presenter

extension EditCategoryAttrViewModelImple {
    
    public var initialName: String { self.category.name }
    
    public var isChangeSavable: Observable<Bool> {
        
        let checkNameWhenExists: (String?) -> Bool = { name in
            guard let name = name else { return true }
            return name.isNotEmpty
        }
        
        return self.subjects.pendingNewName
            .map(checkNameWhenExists)
            .distinctUntilChanged()
    }
    
    public var selectedColorCode: Observable<String> {
        let currentColor = self.category.colorCode
        return self.subjects.pendingNewColorCode
            .compactMap { $0 }
            .startWith(currentColor)
    }
}
