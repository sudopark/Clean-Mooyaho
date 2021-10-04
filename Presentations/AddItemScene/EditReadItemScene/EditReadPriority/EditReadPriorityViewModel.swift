//
//  EditReadPriorityViewModel.swift
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/04.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - EditReadPriorityViewModel

public protocol EditReadPriorityViewModel: AnyObject {

    // interactor
    
    // presenter
}


// MARK: - EditReadPriorityViewModelImple

public final class EditReadPriorityViewModelImple: EditReadPriorityViewModel {
    
    private let router: EditReadPriorityRouting
    private weak var listener: EditReadPrioritySceneListenable?
    
    public init(router: EditReadPriorityRouting,
                listener: EditReadPrioritySceneListenable?) {
        self.router = router
        self.listener = listener
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


// MARK: - EditReadPriorityViewModelImple Interactor

extension EditReadPriorityViewModelImple {
    
}


// MARK: - EditReadPriorityViewModelImple Presenter

extension EditReadPriorityViewModelImple {
    
}
