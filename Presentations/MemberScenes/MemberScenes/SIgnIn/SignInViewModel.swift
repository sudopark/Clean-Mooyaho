//
//  SignInViewModel.swift
//  MemberScenes
//
//  Created sudo.park on 2021/05/29.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting

// MARK: - SignInViewModel

public protocol SignInViewModel: AnyObject {

    // interactor
    func requestSignIn(_ type: OAuthServiceProviderType)
    func requestClose()
    
    // presenter
    var isProcessing: Observable<Bool> { get }
    var supportingOAuthProviderTypes: [OAuthServiceProviderType] { get }
}


// MARK: - SignInViewModelImple

public final class SignInViewModelImple: SignInViewModel {
        
    private let authUsecase: AuthUsecase
    private let router: SignInRouting
    
    public init(authUsecase: AuthUsecase,
                router: SignInRouting) {
        self.authUsecase = authUsecase
        self.router = router
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    fileprivate final class Subjects {
        
        let isProcessing = BehaviorRelay<Bool>(value: false)
        let signedIn = PublishSubject<Void>()
    }
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - SignInViewModelImple Interactor

extension SignInViewModelImple {
    
    private var isSignInProcessing: Bool {
        return self.subjects.isProcessing.value == true
    }
    
    public func requestClose() {
        guard self.isSignInProcessing == false else { return }
        self.router.closeScene(animated: true, completed: nil)
    }
    
    public func requestSignIn(_ type: OAuthServiceProviderType) {
        
        guard self.isSignInProcessing == false else { return }
        
        let showError: (Error) -> Void = { [weak self] error in
            self?.subjects.isProcessing.accept(false)
            self?.router.alertError(error)
            logger.print(level: .warning, "signin fail.. reason: \(error)")
        }
        
        let closeScene: (Member) -> Void = { [weak self] _ in
            self?.router.closeScene(animated: true) {
                self?.subjects.signedIn.onNext()
            }
        }
        
        self.subjects.isProcessing.accept(true)
        self.authUsecase.requestSocialSignIn(type)
            .subscribe(onSuccess: closeScene, onError: showError)
            .disposed(by: self.disposeBag)
    }
}


// MARK: - SignInViewModelImple Presenter

extension SignInViewModelImple {
    
    public var isProcessing: Observable<Bool> {
        return self.subjects.isProcessing.asObservable()
    }
    
    public var supportingOAuthProviderTypes: [OAuthServiceProviderType] {
        return self.authUsecase.supportingOAuthServiceProviders
    }
    
    public var signedIn: Observable<Void> {
        return self.subjects.signedIn
    }
}
