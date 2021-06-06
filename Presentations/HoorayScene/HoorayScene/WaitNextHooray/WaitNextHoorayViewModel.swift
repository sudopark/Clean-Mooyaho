//
//  WaitNextHoorayViewModel.swift
//  HoorayScene
//
//  Created sudo.park on 2021/06/06.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting

// MARK: - WaitNextHoorayViewModel

public protocol WaitNextHoorayViewModel: AnyObject {

    // interactor
    
    // presenter
}


// MARK: - WaitNextHoorayViewModelImple

public final class WaitNextHoorayViewModelImple: WaitNextHoorayViewModel {
    
    private let waitUntil: TimeStamp
    private let router: WaitNextHoorayRouting
    
    public init(waitUntil: TimeStamp, router: WaitNextHoorayRouting) {
        self.waitUntil = waitUntil
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


// MARK: - WaitNextHoorayViewModelImple Interactor

extension WaitNextHoorayViewModelImple {
    
}


// MARK: - WaitNextHoorayViewModelImple Presenter

extension WaitNextHoorayViewModelImple {
    
}
