//
//  
//  LinkMemoRouter.swift
//  ViewerScene
//
//  Created by sudo.park on 2021/10/24.
//
//  ViewerScene
//
//  Created sudo.park on 2021/10/24.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol LinkMemoRouting: Routing { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias LinkMemoRouterBuildables = EmptyBuilder

public final class LinkMemoRouter: Router<LinkMemoRouterBuildables>, LinkMemoRouting { }


extension LinkMemoRouter {
    
    // LinkMemoRouting implements
    private var currentInteractor: LinkMemoSceneInteractable? {
        return (self.currentScene as? LinkMemoScene)?.interactor
    }
}
