//
//  RegisterNewPlaceViewModel.swift
//  PlaceScenes
//
//  Created sudo.park on 2021/06/11.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - RegisterNewPlaceViewModel

public protocol RegisterNewPlaceViewModel: AnyObject {

    // interactor
    
    // presenter
}


// MARK: - RegisterNewPlaceViewModelImple

public final class RegisterNewPlaceViewModelImple: RegisterNewPlaceViewModel {
    
    private let router: RegisterNewPlaceRouting
    
    public init(router: RegisterNewPlaceRouting) {
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


// MARK: - RegisterNewPlaceViewModelImple Interactor

extension RegisterNewPlaceViewModelImple {
    
}


// MARK: - RegisterNewPlaceViewModelImple Presenter

extension RegisterNewPlaceViewModelImple {
    
}
