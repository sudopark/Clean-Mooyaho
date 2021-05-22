//
//  NearbyViewModel.swift
//  LocationScenes
//
//  Created sudo.park on 2021/05/22.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import CommonPresenting

// MARK: - NearbyViewModel

public protocol NearbyViewModel: AnyObject {

    // interactor
    
    // presenter
}


// MARK: - ___VARIABLE_sceneModuleName___ViewModel

public final class NearbyViewModelImple: NearbyViewModel {
    
    fileprivate final class Subjects {
        // define subjects
    }
    
    private let router: NearbyRouting
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    public init(router: NearbyRouting) {
        self.router = router
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
}


// MARK: - ___VARIABLE_sceneModuleName___ViewModel Interactor

extension NearbyViewModelImple {
    
}


// MARK: - ___VARIABLE_sceneModuleName___ViewModel Presenter

extension NearbyViewModelImple {
    
}
