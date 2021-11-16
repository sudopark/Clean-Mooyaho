//
//  
//  SharedCollectionItemsRouter.swift
//  DiscoveryScene
//
//  Created by sudo.park on 2021/11/16.
//
//  DiscoveryScene
//
//  Created sudo.park on 2021/11/16.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Routing

public protocol SharedCollectionItemsRouting: Routing {
    
    func moveToSubCollection(collection: SharedReadCollection)
    
    func showLinkDetail(_ link: SharedReadLink)
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias SharedCollectionItemsRouterBuildables = EmptyBuilder

public final class SharedCollectionItemsRouter: Router<SharedCollectionItemsRouterBuildables>, SharedCollectionItemsRouting { }


extension SharedCollectionItemsRouter {
    
    // SharedCollectionItemsRouting implements
    private var currentInteractor: SharedCollectionItemsSceneInteractable? {
        return (self.currentScene as? SharedCollectionItemsScene)?.interactor
    }
    
    public func moveToSubCollection(collection: SharedReadCollection) {
        logger.todoImplement()
    }
    
    public func showLinkDetail(_ link: SharedReadLink) {
        logger.todoImplement()
    }
}
