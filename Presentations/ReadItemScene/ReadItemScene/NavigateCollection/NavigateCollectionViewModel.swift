//
//  NavigateCollectionViewModel.swift
//  ReadItemScene
//
//  Created sudo.park on 2021/10/26.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - NavigateCollectionViewModel

public protocol NavigateCollectionViewModel: AnyObject {

    // interactor
    
    // presenter
}


// MARK: - NavigateCollectionViewModelImple

public final class NavigateCollectionViewModelImple: NavigateCollectionViewModel {
    
    private let router: NavigateCollectionRouting
    private weak var listener: NavigateCollectionSceneListenable?
    
    public init(router: NavigateCollectionRouting,
                listener: NavigateCollectionSceneListenable?) {
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


// MARK: - NavigateCollectionViewModelImple Interactor

extension NavigateCollectionViewModelImple {
    
}


// MARK: - NavigateCollectionViewModelImple Presenter

extension NavigateCollectionViewModelImple {
    
}
