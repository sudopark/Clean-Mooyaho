//
//  EnterHoorayMessageViewModel.swift
//  HoorayScene
//
//  Created sudo.park on 2021/06/07.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting

// MARK: - EnterHoorayMessageViewModel

public protocol EnterHoorayMessageViewModel: AnyObject {

    // interactor
    
    // presenter
}


// MARK: - EnterHoorayMessageViewModelImple

public final class EnterHoorayMessageViewModelImple: EnterHoorayMessageViewModel {
    
    private let router: EnterHoorayMessageRouting
    
    public init(router: EnterHoorayMessageRouting) {
        self.router = router
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    fileprivate final class Subjects {
        
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - EnterHoorayMessageViewModelImple Interactor

extension EnterHoorayMessageViewModelImple {
    
}


// MARK: - EnterHoorayMessageViewModelImple Presenter

extension EnterHoorayMessageViewModelImple {
    
}
