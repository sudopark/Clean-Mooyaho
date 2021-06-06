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
public typealias MakeHoorayRouterBuildables = EditProfileSceneBuilable

public final class MakeHoorayRouter: Router<MakeHoorayRouterBuildables>, MakeHoorayRouting { }


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
        logger.todoImplement()
    }
}
