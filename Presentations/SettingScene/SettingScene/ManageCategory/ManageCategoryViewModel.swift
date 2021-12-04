//
//  ManageCategoryViewModel.swift
//  SettingScene
//
//  Created sudo.park on 2021/12/03.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - ManageCategoryViewModel

public struct CategoryCellViewModel: Equatable {
    let uid: String
    let name: String
    let colorCode: String
}

public protocol ManageCategoryViewModel: AnyObject {

    // interactor
    func refresh()
    func loadMore()
    func editCategory(_ uid: String)
    func removeCategory(_ uid: String)
    
    // presenter
    var cellViewModels: Observable<[CategoryCellViewModel]> { get }
}


// MARK: - ManageCategoryViewModelImple

public final class ManageCategoryViewModelImple: ManageCategoryViewModel {
    
    private let categoryUsecase: ReadItemCategoryUsecase
    private let router: ManageCategoryRouting
    private weak var listener: ManageCategorySceneListenable?
    
    public init(categoryUsecase: ReadItemCategoryUsecase,
                router: ManageCategoryRouting,
                listener: ManageCategorySceneListenable?) {
        
        self.categoryUsecase = categoryUsecase
        self.router = router
        self.listener = listener
        
        self.bindPaging()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
        
        let requestTime = PublishSubject<TimeStamp>()
        let categories = BehaviorRelay<[ItemCategory]?>(value: nil)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private var isLoadedAll = false
    
    private func bindPaging() {
        
        let loadCategories: (TimeStamp) -> Maybe<[ItemCategory]> = { [weak self] time in
            guard let self = self else { return .empty() }
            return self.categoryUsecase.loadCategories(earilerThan: time)
                .catch { _ in .empty() }
        }
        
        let appendNewCategories: ([ItemCategory]) -> Void = { [weak self] categories in
            guard let self = self else { return }
            self.isLoadedAll = categories.isEmpty
            self.appendCategoriesWithRemoveDuplicating(categories)
        }
        
        self.subjects.requestTime
            .flatMapLatest(loadCategories)
            .subscribe(onNext: appendNewCategories)
            .disposed(by: self.disposeBag)
    }
    
    private func appendCategoriesWithRemoveDuplicating(_ categories: [ItemCategory]) {
        let newCategories = ((self.subjects.categories.value ?? []) + categories).removeDuplicated { $0.uid }
        self.subjects.categories.accept(newCategories)
    }
}


// MARK: - ManageCategoryViewModelImple Interactor

extension ManageCategoryViewModelImple {
    
    
    public func refresh() {
        
        let time = self.subjects.categories.value?.last?.createdAt ?? .now()
        self.subjects.requestTime.onNext(time)
    }
    
    public func loadMore() {
        
        guard self.isLoadedAll == false,
                let last = self.subjects.categories.value?.last?.createdAt else { return }
        self.subjects.requestTime.onNext(last)
    }
    
    public func editCategory(_ uid: String) {
        guard let categories = self.subjects.categories.value,
              let category = categories.first(where: { $0.uid == uid })
        else {
            return
        }
        self.router.moveToEditCategory(category)
    }
    
    public func removeCategory(_ uid: String) {
        
        let removeConfirmed: () -> Void = { [weak self] in
            self?.doRemoveCategory(uid)
        }
        
        guard let form = AlertBuilder(base: .init())
                .title("Remove category")
                .message("TBD message")
                .confirmed(removeConfirmed)
                .build()
        else {
            return
        }
        self.router.alertForConfirm(form)
    }
    
    private func doRemoveCategory(_ uid: String) {
        
        let removed: () -> Void = { [weak self] in
            guard let self = self else { return }
            let newCategories = (self.subjects.categories.value ?? []).filter { $0.uid != uid }
            self.subjects.categories.accept(newCategories)
        }
        let handleError: (Error) -> Void = { [weak self] error in
            self?.router.alertError(error)
        }
        self.categoryUsecase.deleteCategory(uid)
            .subscribe(onSuccess: removed,
                       onError: handleError)
            .disposed(by: self.disposeBag)
    }
}


// MARK: - ManageCategoryViewModelImple Presenter

extension ManageCategoryViewModelImple {
    
    public var cellViewModels: Observable<[CategoryCellViewModel]> {
        return self.subjects.categories
            .compactMap { $0?.asCellViewModels() }
            .distinctUntilChanged()
    }
}


private extension Array where Element == ItemCategory {
    
    func asCellViewModels() -> [CategoryCellViewModel] {
        return self.map {
            return .init(uid: $0.uid, name: $0.name, colorCode: $0.colorCode)
        }
    }
}
