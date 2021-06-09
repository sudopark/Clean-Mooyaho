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
    
    func openEnterHoorayImageScene(_ form: NewHoorayForm) -> EnteringNewHoorayPresenter?
    
    func openEnterHoorayMessageScene(_ form: NewHoorayForm) -> EnteringNewHoorayPresenter?
    
    func openEnterHoorayTagScene(_ form: NewHoorayForm) -> EnteringNewHoorayPresenter?
    
    func presentPlaceSelectScene(_ form: NewHoorayForm) -> EnteringNewHoorayPresenter?
    
    func alertShouldWaitPublishNewHooray(_ until: TimeStamp)

}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias MakeHoorayRouterBuildables = MakeHooraySceneBuilable & EditProfileSceneBuilable & WaitNextHooraySceneBuilable

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
    
    public func openEnterHoorayImageScene(_ form: NewHoorayForm) -> EnteringNewHoorayPresenter? {
        return routeToEnteringScenes(form, nextMake: self.nextScenesBuilder?.makeEnterHoorayImageScene(form:))
    }
    
    public func openEnterHoorayMessageScene(_ form: NewHoorayForm) -> EnteringNewHoorayPresenter? {
        return routeToEnteringScenes(form, nextMake: self.nextScenesBuilder?.makeEnterHoorayMessageScene(form:))
    }
    
    public func openEnterHoorayTagScene(_ form: NewHoorayForm) -> EnteringNewHoorayPresenter? {
        return routeToEnteringScenes(form, nextMake: self.nextScenesBuilder?.makeEnterHoorayTagScene(form:))
    }
    
    typealias EnteringScene = BaseEnterNewHoorayInfoScene & PangestureDismissableScene
    private func routeToEnteringScenes(_ form: NewHoorayForm,
                                       nextMake: ((NewHoorayForm) -> EnteringScene)?) -> EnteringNewHoorayPresenter? {
        guard let next = nextMake?(form) else { return nil }
        next.modalPresentationStyle = .custom
        next.transitioningDelegate = self.bottomSliderTransitionManager
        next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
        self.currentScene?.present(next, animated: true, completion: nil)
        return next.presenter
    }
    
    public func presentPlaceSelectScene(_ form: NewHoorayForm) -> EnteringNewHoorayPresenter? {
        guard let next = self.nextScenesBuilder?.makeSelectHoorayPlaceScene(form: form) else { return nil }
        self.currentScene?.present(next, animated: true, completion: nil)
        return next.presenter
    }
    
    public func alertShouldWaitPublishNewHooray(_ until: TimeStamp) {
        
        guard let next = self.nextScenesBuilder?.makeWaitNextHoorayScene(until) else { return }
        next.modalPresentationStyle = .custom
        next.transitioningDelegate = self.bottomSliderTransitionManager
        next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
        self.currentScene?.present(next, animated: true, completion: nil)
    }
}
