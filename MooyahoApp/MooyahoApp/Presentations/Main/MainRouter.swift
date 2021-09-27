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

import Domain
import CommonPresenting
import ReadItemScene


// MARK: - Routing

public protocol MainRouting: Routing {

    func addReadCollectionScene()
    
    func openSlideMenu()
    
    func presentSignInScene() -> SignInScenePresenter?
    
    func presentEditProfileScene() -> EditProfileScenePresenter?
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias MainRouterBuildables = MainSlideMenuSceneBuilable
    & SignInSceneBuilable & EditProfileSceneBuilable & ReadCollectionSceneBuilable

public final class MainRouter: Router<MainRouterBuildables>, MainRouting {
    
    private let pushSlideTransitionManager = PushslideTransitionAnimationManager()
    private let bottomSliderTransitionManager = BottomSlideTransitionAnimationManager()
}


extension MainRouter {
    
    public func addReadCollectionScene() {
        
        guard let mainScene = self.currentScene as? MainScene,
              let collectionScene = self.nextScenesBuilder?.makeReadCollectionScene(collectionID: nil) else {
            return
        }
        
        let navigationController = UINavigationController(rootViewController: collectionScene)
        navigationController.isNavigationBarHidden = true
        
        navigationController.view.frame = CGRect(origin: .zero, size: mainScene.childContainerView.frame.size)
        navigationController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainScene.addChild(navigationController)
        mainScene.childContainerView.addSubview(navigationController.view)
        navigationController.didMove(toParent: mainScene)
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
    
//    public func alertShouldWaitPublishNewHooray(_ until: TimeStamp) {
//
//        guard let next = self.nextScenesBuilder?.makeWaitNextHoorayScene(until) else { return }
//        next.modalPresentationStyle = .custom
//        next.transitioningDelegate = self.bottomSliderTransitionManager
//        next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
//        self.currentScene?.present(next, animated: true, completion: nil)
//    }
//
//    public func presentMakeNewHoorayScene() {
//
//        guard let next = self.nextScenesBuilder?.makeMakeHoorayScene() else { return }
//        self.currentScene?.present(next, animated: true, completion: nil)
//    }
}
