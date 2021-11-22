//
//  
//  IntegratedSearchRouter.swift
//  SuggestScene
//
//  Created by sudo.park on 2021/11/23.
//
//  SuggestScene
//
//  Created sudo.park on 2021/11/23.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol IntegratedSearchRouting: Routing { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias IntegratedSearchRouterBuildables = EmptyBuilder

public final class IntegratedSearchRouter: Router<IntegratedSearchRouterBuildables>, IntegratedSearchRouting { }


extension IntegratedSearchRouter {
    
    // IntegratedSearchRouting implements
    private var currentInteractor: IntegratedSearchSceneInteractable? {
        return (self.currentScene as? IntegratedSearchScene)?.interactor
    }
}
