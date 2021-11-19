//
//  
//  SharedCollectionInfoDialogRouter.swift
//  DiscoveryScene
//
//  Created by sudo.park on 2021/11/20.
//
//  DiscoveryScene
//
//  Created sudo.park on 2021/11/20.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol SharedCollectionInfoDialogRouting: Routing { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias SharedCollectionInfoDialogRouterBuildables = EmptyBuilder

public final class SharedCollectionInfoDialogRouter: Router<SharedCollectionInfoDialogRouterBuildables>, SharedCollectionInfoDialogRouting { }


extension SharedCollectionInfoDialogRouter {
    
    // SharedCollectionInfoDialogRouting implements
    private var currentInteractor: SharedCollectionInfoDialogSceneInteractable? {
        return (self.currentScene as? SharedCollectionInfoDialogScene)?.interactor
    }
}
