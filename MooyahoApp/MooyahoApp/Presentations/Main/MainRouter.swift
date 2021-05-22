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
import LocationScenes


// MARK: - Routing

public protocol MainRouting: Routing {
    
    func addNearbySceen()
    
    func openSlideMenu()
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias MainRouterBuildables = MainSlideMenuSceneBuilable & NearbySceneBuilable

public final class MainRouter: Router<MainRouterBuildables>, MainRouting {
    
    private let pushSlideTransitionManager = PushslideTransitionAnimationManager()
}


extension MainRouter {
    
    public func addNearbySceen() {
        guard let mainScene = self.currentScene as? MainScene,
              let nearbyScene = self.nextScenesBuilder?.makeNearbyScene() else { return }
        
        nearbyScene.view.frame = CGRect(origin: .zero, size: mainScene.childContainerView.frame.size)
        nearbyScene.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainScene.addChild(nearbyScene)
        mainScene.childContainerView.addSubview(nearbyScene.view)
        nearbyScene.didMove(toParent: mainScene)
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
}
