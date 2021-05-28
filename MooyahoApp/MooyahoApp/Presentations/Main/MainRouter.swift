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
import MemberScenes
import LocationScenes


// MARK: - Routing

public protocol MainRouting: Routing {
    
    func addNearbySceen(_ listener: @escaping Listener<NearbySceneEvents>) -> NearbySceneCommandListener?
    
    func openSlideMenu()
    
    func presentSignInScene()
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias MainRouterBuildables = MainSlideMenuSceneBuilable & NearbySceneBuilable & SignInSceneBuilable

public final class MainRouter: Router<MainRouterBuildables>, MainRouting {
    
    private let pushSlideTransitionManager = PushslideTransitionAnimationManager()
    private let bottomSliderTransitionManager = BottomSlideTransitionAnimationManager()
}


extension MainRouter {
    
    public func addNearbySceen(_ listener: @escaping Listener<NearbySceneEvents>) -> NearbySceneCommandListener? {
        guard let mainScene = self.currentScene as? MainScene,
              let nearbyScene = self.nextScenesBuilder?.makeNearbyScene(listener) else { return nil }
        
        nearbyScene.view.frame = CGRect(origin: .zero, size: mainScene.childContainerView.frame.size)
        nearbyScene.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainScene.addChild(nearbyScene)
        mainScene.childContainerView.addSubview(nearbyScene.view)
        nearbyScene.didMove(toParent: mainScene)
        
        return nearbyScene
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
    
    public func presentSignInScene() {
        
        guard let scene = self.nextScenesBuilder?.makeSignInScene() else { return }
        
        scene.modalPresentationStyle = .custom
        scene.transitioningDelegate = self.bottomSliderTransitionManager
        scene.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
        self.currentScene?.present(scene, animated: true, completion: nil)
    }
}
