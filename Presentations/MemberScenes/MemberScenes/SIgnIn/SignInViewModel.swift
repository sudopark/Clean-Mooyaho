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

import CommonPresenting

// MARK: - SignInViewModel

public protocol SignInViewModel: AnyObject {

    // interactor
    
    // presenter
}


// MARK: - ___VARIABLE_sceneModuleName___ViewModel

public final class SignInViewModelImple: SignInViewModel {
    
    fileprivate final class Subjects {
        // define subjects
    }
    
    private let router: SignInRouting
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    public init(router: SignInRouting) {
        self.router = router
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
}


// MARK: - ___VARIABLE_sceneModuleName___ViewModel Interactor

extension SignInViewModelImple {
    
}


// MARK: - ___VARIABLE_sceneModuleName___ViewModel Presenter

extension SignInViewModelImple {
    
}
