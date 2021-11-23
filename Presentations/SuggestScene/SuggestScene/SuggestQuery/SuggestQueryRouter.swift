//
//  
//  SuggestQueryRouter.swift
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

public protocol SuggestQueryRouting: Routing { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias SuggestQueryRouterBuildables = EmptyBuilder

public final class SuggestQueryRouter: Router<SuggestQueryRouterBuildables>, SuggestQueryRouting { }


extension SuggestQueryRouter {
    
    // SuggestQueryRouting implements
    private var currentInteractor: SuggestQuerySceneInteractable? {
        return (self.currentScene as? SuggestQueryScene)?.interactor
    }
}
