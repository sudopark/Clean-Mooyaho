//
//  
//  MakeHoorayRouter.swift
//  HoorayScene
//
//  Created by sudo.park on 2021/06/04.
//
//  HoorayScene
//
//  Created sudo.park on 2021/06/04.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Routing

public protocol MakeHoorayRouting: Routing {
    
    func openEditProfileScene() -> EditProfileScenePresenter?
    
    func presentPlaceSelectScene()
    
    func askSelectPlaceInfo(_ form: AlertForm)
    
    func alertShouldWaitPublishNewHooray(_ until: TimeStamp)
    
//    func unavailToPublish
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias MakeHoorayRouterBuildables = EditProfileSceneBuilable & WaitNextHooraySceneBuilable

public final class MakeHoorayRouter: Router<MakeHoorayRouterBuildables>, MakeHoorayRouting {
    
    private let bottomSliderTransitionManager = BottomSlideTransitionAnimationManager()
}


extension MakeHoorayRouter {
    
    // MakeHoorayRouting implements
    public func openEditProfileScene() -> EditProfileScenePresenter? {
        guard let next = self.nextScenesBuilder?.makeEditProfileScene() else { return nil }
        self.currentScene?.present(next, animated: true, completion: nil)
        return next.presenrer
    }
    
    public func presentPlaceSelectScene() {
        logger.todoImplement()
    }
    
    public func askSelectPlaceInfo(_ form: AlertForm) {
        logger.todoImplement()
    }
    
    public func alertShouldWaitPublishNewHooray(_ until: TimeStamp) {
        
        guard let next = self.nextScenesBuilder?.makeWaitNextHoorayScene() else { return }
        next.modalPresentationStyle = .custom
        next.transitioningDelegate = self.bottomSliderTransitionManager
        next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
        self.currentScene?.present(next, animated: true, completion: nil)
    }
}
