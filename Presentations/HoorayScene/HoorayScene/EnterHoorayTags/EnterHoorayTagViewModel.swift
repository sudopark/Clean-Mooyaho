//
//  EnterHoorayTagViewModel.swift
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


// MARK: - EnterHoorayTagViewModel

public protocol EnterHoorayTagViewModel: AnyObject {

    // interactor
    
    // presenter
}


// MARK: - EnterHoorayTagViewModelImple

public final class EnterHoorayTagViewModelImple: EnterHoorayTagViewModel {
    
    private let router: EnterHoorayTagRouting
    
    public init(router: EnterHoorayTagRouting) {
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


// MARK: - EnterHoorayTagViewModelImple Interactor

extension EnterHoorayTagViewModelImple {
    
}


// MARK: - EnterHoorayTagViewModelImple Presenter

extension EnterHoorayTagViewModelImple {
    
}
