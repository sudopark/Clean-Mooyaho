//
//  
//  MainRouter.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/05/20.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//
//  MooyahoApp
//
//  Created sudo.park on 2021/05/20.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import RxSwift

import CommonPresenting


// MARK: - Routing

public protocol MainRouting: Routing {
    
    func addNearbySceen() -> (ineteractor: NearbySceneInteractor?, presenter: NearbyScenePresenter?)
    
    func openSlideMenu()
    
    func presentSignInScene() -> SignInScenePresenter?
    
    func presentEditProfileScene() -> EditProfileScenePresenter?
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias MainRouterBuildables = MainSlideMenuSceneBuilable & NearbySceneBuilable
    & SignInSceneBuilable & EditProfileSceneBuilable

public final class MainRouter: Router<MainRouterBuildables>, MainRouting {
    
    private let pushSlideTransitionManager = PushslideTransitionAnimationManager()
    private let bottomSliderTransitionManager = BottomSlideTransitionAnimationManager()
}


extension MainRouter {
    
    public func addNearbySceen() -> (ineteractor: NearbySceneInteractor?, presenter: NearbyScenePresenter?) {
        guard let mainScene = self.currentScene as? MainScene,
              let nearbyScene = self.nextScenesBuilder?.makeNearbyScene() else { return (nil, nil) }
        
        nearbyScene.view.frame = CGRect(origin: .zero, size: mainScene.childContainerView.frame.size)
        nearbyScene.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainScene.addChild(nearbyScene)
        mainScene.childContainerView.addSubview(nearbyScene.view)
        nearbyScene.didMove(toParent: mainScene)
        
        return (nearbyScene.interactor, nearbyScene.presenter)
    }
    
    public func openSlideMenu() {
        
        guard let menuScene = self.nextScenesBuilder?.makeMainSlideMenuScene() else {
            return
        }
        
        menuScene.modalPresentationStyle = .custom
        menuScene.transitioningDelegate = self.pushSlideTransitionManager
        menuScene.setupDismissGesture(self.pushSlideTransitionManager.dismissalInteractor)
        self.currentScene?.present(menuScene, animated: true, completion: nil)
    }
    
    public func presentSignInScene() -> SignInScenePresenter? {
        
        guard let scene = self.nextScenesBuilder?.makeSignInScene() else { return nil }
        
        scene.modalPresentationStyle = .custom
        scene.transitioningDelegate = self.bottomSliderTransitionManager
        self.currentScene?.present(scene, animated: true, completion: nil)
        
        return scene.presenter
    }
    
    public func presentEditProfileScene() -> EditProfileScenePresenter? {
        
        guard let scene = self.nextScenesBuilder?.makeEditProfileScene() else { return nil }
        self.currentScene?.present(scene, animated: true, completion: nil)
        return scene.presenrer
    }
}
