//
//  AddItemNavigationViewModel.swift
//  AddItemScene
//
//  Created sudo.park on 2021/10/02.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - AddItemNavigationViewModel

public protocol AddItemNavigationViewModel: AnyObject {

    // interactor
    
    // presenter
}


// MARK: - AddItemNavigationViewModelImple

public final class AddItemNavigationViewModelImple: AddItemNavigationViewModel {
    
    private let router: AddItemNavigationRouting
    
    public init(router: AddItemNavigationRouting) {
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


// MARK: - AddItemNavigationViewModelImple Interactor

extension AddItemNavigationViewModelImple {
    
}


// MARK: - AddItemNavigationViewModelImple Presenter

extension AddItemNavigationViewModelImple {
    
}
