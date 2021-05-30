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
    
    // presenter
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
        // define subjects
    }
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - SignInViewModelImple Interactor

extension SignInViewModelImple {
    
}


// MARK: - SignInViewModelImple Presenter

extension SignInViewModelImple {
    
}
