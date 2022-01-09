//
//  
//  FeedbackRouter.swift
//  SettingScene
//
//  Created by sudo.park on 2021/12/15.
//
//  SettingScene
//
//  Created sudo.park on 2021/12/15.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol FeedbackRouting: Routing { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias FeedbackRouterBuildables = EmptyBuilder

public final class FeedbackRouter: Router<FeedbackRouterBuildables>, FeedbackRouting { }


extension FeedbackRouter {
    
    // FeedbackRouting implements
    private var currentInteractor: FeedbackSceneInteractable? {
        return (self.currentScene as? FeedbackScene)?.interactor
    }
}
