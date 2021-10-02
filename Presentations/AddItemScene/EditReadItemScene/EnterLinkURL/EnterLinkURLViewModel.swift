//
//  EnterLinkURLViewModel.swift
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/02.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - EnterLinkURLViewModel

public protocol EnterLinkURLViewModel: AnyObject {

    // interactor
    
    // presenter
}


// MARK: - EnterLinkURLViewModelImple

public final class EnterLinkURLViewModelImple: EnterLinkURLViewModel {
    
    private let router: EnterLinkURLRouting
    
    public init(router: EnterLinkURLRouting) {
        self.router = router
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
        
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - EnterLinkURLViewModelImple Interactor

extension EnterLinkURLViewModelImple {
    
}


// MARK: - EnterLinkURLViewModelImple Presenter

extension EnterLinkURLViewModelImple {
    
}
