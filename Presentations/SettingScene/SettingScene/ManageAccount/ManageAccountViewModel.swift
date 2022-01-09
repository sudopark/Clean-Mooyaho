//
//  ManageAccountViewModel.swift
//  SettingScene
//
//  Created sudo.park on 2021/12/06.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


public enum ManageAccountCellViewModel {
    case signout
    case withdrawal
    case withdrawalDescription
}


// MARK: - ManageAccountViewModel

public protocol ManageAccountViewModel: AnyObject {

    // interactor
    func signout()
    func withdrawal()
    
    // presenter
    var cellViewModels: Observable<[[ManageAccountCellViewModel]]> { get }
    var isProcessing: Observable<Bool> { get }
}


// MARK: - ManageAccountViewModelImple

public final class ManageAccountViewModelImple: ManageAccountViewModel {
    
    private let authUsecase: AuthUsecase
    private let router: ManageAccountRouting
    private weak var listener: ManageAccountSceneListenable?
    
    public init(authUsecase: AuthUsecase,
                router: ManageAccountRouting,
                listener: ManageAccountSceneListenable?) {
        
        self.authUsecase = authUsecase
        self.router = router
        self.listener = listener
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
        let isProcessing = BehaviorRelay<Bool>(value: false)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - ManageAccountViewModelImple Interactor

extension ManageAccountViewModelImple {
    
    public func signout() {
        
        guard self.subjects.isProcessing.value == false else { return }
        self.subjects.isProcessing.accept(true)
        
        self.authUsecase.requestSignout()
            .subscribe(onError: self.handleError())
            .disposed(by: self.disposeBag)
    }
    
    public func withdrawal() {
        
        guard self.subjects.isProcessing.value == false else { return }
        
        let confirmed: () -> Void = { [weak self] in
            self?.withdrawalAfterConfirm()
        }
        guard let form = AlertBuilder(base: .init())
                .title("Delete account".localized)
                .message("Are you sure you want to delete your account?".localized)
                .confirmed(confirmed)
                .build()
        else {
            return
        }
        self.router.alertForConfirm(form)
    }
    
    private func withdrawalAfterConfirm() {
        self.subjects.isProcessing.accept(true)
        
        self.authUsecase.requestWithdrawal()
            .subscribe(onError: self.handleError())
            .disposed(by: self.disposeBag)
    }
    
    private func handleError() -> (Error) -> Void {
        return { [weak self] error in
            self?.subjects.isProcessing.accept(false)
            self?.router.alertError(error)
        }
    }
}


// MARK: - ManageAccountViewModelImple Presenter

extension ManageAccountViewModelImple {
    
    public var cellViewModels: Observable<[[ManageAccountCellViewModel]]> {
        return .just([
            [.signout],
            [.withdrawal, .withdrawalDescription]
        ])
    }
    
    public var isProcessing: Observable<Bool> {
        return self.subjects.isProcessing
            .asObservable()
    }
}
