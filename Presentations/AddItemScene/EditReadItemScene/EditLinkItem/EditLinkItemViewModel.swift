//
//  EditLinkItemViewModel.swift
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/03.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - EditLinkItemViewModel

public protocol EditLinkItemViewModel: AnyObject {

    // interactor
    
    // presenter
}


// MARK: - EditLinkItemViewModelImple

public final class EditLinkItemViewModelImple: EditLinkItemViewModel {
    
    private let router: EditLinkItemRouting
    
    public init(case: EditLinkItemCase,
                router: EditLinkItemRouting,
                completed: @escaping (ReadLink) -> Void) {
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


// MARK: - EditLinkItemViewModelImple Interactor

extension EditLinkItemViewModelImple {
    
}


// MARK: - EditLinkItemViewModelImple Presenter

extension EditLinkItemViewModelImple {
    
}
