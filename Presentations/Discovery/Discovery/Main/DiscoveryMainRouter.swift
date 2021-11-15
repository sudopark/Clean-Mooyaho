//
//  
//  DiscoveryMainRouter.swift
//  DiscoveryScene
//
//  Created by sudo.park on 2021/11/14.
//
//  DiscoveryScene
//
//  Created sudo.park on 2021/11/14.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Routing

public protocol DiscoveryMainRouting: Routing {
    
    func viewAllSharedCollections()
    
    func routeToSharedCollection(_ collection: SharedReadCollection)
    
    func routeToMyReadCollection()
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias DiscoveryMainRouterBuildables = EmptyBuilder

public final class DiscoveryMainRouter: Router<DiscoveryMainRouterBuildables>, DiscoveryMainRouting {
    
    public weak var collectionMainInteractor: ReadCollectionMainSceneInteractable?
}


extension DiscoveryMainRouter {
    
    // DiscoveryMainRouting implements
    private var currentInteractor: DiscoveryMainSceneInteractable? {
        return (self.currentScene as? DiscoveryMainScene)?.interactor
    }
    
    public func viewAllSharedCollections() {
        logger.todoImplement()
    }
    
    public func routeToSharedCollection(_ collection: SharedReadCollection) {
        self.collectionMainInteractor?.switchToSharedCollection(collection)
    }
    
    public func routeToMyReadCollection() {
        self.collectionMainInteractor?.switchToMyReadCollections()
    }
}
