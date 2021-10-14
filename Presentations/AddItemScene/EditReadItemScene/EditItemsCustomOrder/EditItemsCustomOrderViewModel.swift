//
//  EditItemsCustomOrderViewModel.swift
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/15.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - EditItemsCustomOrderViewModel

public protocol EditItemsCustomOrderViewModel: AnyObject {

    // interactor
    
    // presenter
}


// MARK: - EditItemsCustomOrderViewModelImple

public final class EditItemsCustomOrderViewModelImple: EditItemsCustomOrderViewModel {
    
    private let router: EditItemsCustomOrderRouting
    private weak var listener: EditItemsCustomOrderSceneListenable?
    
    public init(router: EditItemsCustomOrderRouting,
                listener: EditItemsCustomOrderSceneListenable?) {
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


// MARK: - EditItemsCustomOrderViewModelImple Interactor

extension EditItemsCustomOrderViewModelImple {
    
}


// MARK: - EditItemsCustomOrderViewModelImple Presenter

extension EditItemsCustomOrderViewModelImple {
    
}
