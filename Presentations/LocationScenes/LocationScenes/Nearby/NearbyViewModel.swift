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

import Domain
import CommonPresenting

// MARK: - NearbyViewModel

public protocol NearbyViewModel: AnyObject {

    // interactor
    
    // presenter
}


// MARK: - NearbyViewModelImple

public final class NearbyViewModelImple: NearbyViewModel {
    
    fileprivate final class Subjects {
        // define subjects
    }
    
    private let locationUsecase: UserLocationUsecase
    private let router: NearbyRouting
    
    public init(locationUsecase: UserLocationUsecase, router: NearbyRouting) {
        self.locationUsecase = locationUsecase
        self.router = router
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - NearbyViewModelImple Interactor

extension NearbyViewModelImple {
    
}


// MARK: - NearbyViewModelImple Presenter

extension NearbyViewModelImple {
    
}
