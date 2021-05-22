//
//  MainSlideMenuViewModel.swift
//  MooyahoApp
//
//  Created sudo.park on 2021/05/21.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import CommonPresenting

// MARK: - MainSlideMenuViewModel

public protocol MainSlideMenuViewModel: AnyObject {

    // interactor
    func closeMenu()
    
    // presenter
}


// MARK: - MainSlideMenuViewModelImple

public final class MainSlideMenuViewModelImple: MainSlideMenuViewModel {
    
    fileprivate final class Subjects {
        // define subjects
    }
    
    private let router: MainSlideMenuRouting
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
  
    public init(router: MainSlideMenuRouting) {
        self.router = router
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
}


// MARK: - MainSlideMenuViewModelImple Interactor

extension MainSlideMenuViewModelImple {
    
    public func closeMenu() {
        self.router.closeMenu()
    }
}


// MARK: - MainSlideMenuViewModelImple Presenter

extension MainSlideMenuViewModelImple {
    
}
