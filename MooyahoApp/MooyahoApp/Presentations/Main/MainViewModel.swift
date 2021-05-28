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
import LocationScenes
import CommonPresenting

// MARK: - MainViewModel

public protocol MainViewModel: AnyObject {

    // interactor
    func setupSubScenes()
    func openSlideMenu()
    func moveMapCameraToCurrentUserPosition()
    
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
    
    private weak var nearbySceneActionListener: NearbySceneCommandListener?
    
    public init(router: MainRouting) {
        self.router = router
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
}


// MARK: - MainViewModelImple Interactor

extension MainViewModelImple {
    
    public func setupSubScenes() {
        
        self.nearbySceneActionListener = self.router.addNearbySceen { [weak self] event in
            // TODO: handle events..
        }
    }
    
    public func openSlideMenu() {
        self.router.openSlideMenu()
    }
    
    public func moveMapCameraToCurrentUserPosition() {
        self.nearbySceneActionListener?.moveMapCameraToCurrentUserPosition()
    }
}


// MARK: - MainViewModelImple Presenter

extension MainViewModelImple {
    
}
