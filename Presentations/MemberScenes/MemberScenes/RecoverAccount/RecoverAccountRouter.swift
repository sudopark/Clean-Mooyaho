//
//  
//  RecoverAccountRouter.swift
//  MemberScenes
//
//  Created by sudo.park on 2022/01/09.
//
//  MemberScenes
//
//  Created sudo.park on 2022/01/09.
//  Copyright © 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol RecoverAccountRouting: Routing { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias RecoverAccountRouterBuildables = EmptyBuilder

public final class RecoverAccountRouter: Router<RecoverAccountRouterBuildables>, RecoverAccountRouting { }


extension RecoverAccountRouter {
    
    // RecoverAccountRouting implements
    private var currentInteractor: RecoverAccountSceneInteractable? {
        return (self.currentScene as? RecoverAccountScene)?.interactor
    }
}
