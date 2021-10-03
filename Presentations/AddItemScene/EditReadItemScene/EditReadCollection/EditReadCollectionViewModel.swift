//
//  EditReadCollectionViewModel.swift
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


// MARK: - EditReadCollectionViewModel

public protocol EditReadCollectionViewModel: AnyObject {

    // interactor
    
    // presenter
}


// MARK: - EditReadCollectionViewModelImple

public final class EditReadCollectionViewModelImple: EditReadCollectionViewModel {
    
    private let router: EditReadCollectionRouting
    
    public init(router: EditReadCollectionRouting) {
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


// MARK: - EditReadCollectionViewModelImple Interactor

extension EditReadCollectionViewModelImple {
    
}


// MARK: - EditReadCollectionViewModelImple Presenter

extension EditReadCollectionViewModelImple {
    
}
