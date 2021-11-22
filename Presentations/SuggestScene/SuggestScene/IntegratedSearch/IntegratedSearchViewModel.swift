//
//  IntegratedSearchViewModel.swift
//  SuggestScene
//
//  Created sudo.park on 2021/11/23.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - IntegratedSearchViewModel

public protocol IntegratedSearchViewModel: AnyObject {

    // interactor
    
    // presenter
}


// MARK: - IntegratedSearchViewModelImple

public final class IntegratedSearchViewModelImple: IntegratedSearchViewModel {
    
    private let router: IntegratedSearchRouting
    private weak var listener: IntegratedSearchSceneListenable?
    
    public init(router: IntegratedSearchRouting,
                listener: IntegratedSearchSceneListenable?) {
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


// MARK: - IntegratedSearchViewModelImple Interactor

extension IntegratedSearchViewModelImple {
    
}


// MARK: - IntegratedSearchViewModelImple Presenter

extension IntegratedSearchViewModelImple {
    
}
