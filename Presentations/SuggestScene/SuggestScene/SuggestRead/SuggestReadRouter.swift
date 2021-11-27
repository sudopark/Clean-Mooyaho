//
//  
//  SuggestReadRouter.swift
//  SuggestScene
//
//  Created by sudo.park on 2021/11/27.
//
//  SuggestScene
//
//  Created sudo.park on 2021/11/27.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol SuggestReadRouting: Routing { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias SuggestReadRouterBuildables = EmptyBuilder

public final class SuggestReadRouter: Router<SuggestReadRouterBuildables>, SuggestReadRouting { }


extension SuggestReadRouter {
    
    // SuggestReadRouting implements
    private var currentInteractor: SuggestReadSceneInteractable? {
        return (self.currentScene as? SuggestReadScene)?.interactor
    }
}
