//
//  MainViewModel.swift
//  MooyahoApp
//
//  Created sudo.park on 2021/05/20.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting

// MARK: - MainViewModel

public protocol MainViewModel: AnyObject {

    // interactor
    func viewDidLoaded()
    func openSlideMenu()
    
    // presenter
}


// MARK: - MainViewModelImple

public final class MainViewModelImple: MainViewModel {
    
    fileprivate final class Subjects {
        // define subjects
    }
    
    private let router: MainRouting
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    public init(router: MainRouting) {
        self.router = router
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
}


// MARK: - MainViewModelImple Interactor

extension MainViewModelImple {
    
    public func viewDidLoaded() {
        self.router.addNearbySceen { [weak self] event in
            // TODO: handle events..
        }
    }
    
    public func openSlideMenu() {
        self.router.openSlideMenu()
    }
}


// MARK: - MainViewModelImple Presenter

extension MainViewModelImple {
    
}
