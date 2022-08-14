//
//  
//  AllSharedCollectionsRouter.swift
//  DiscoveryScene
//
//  Created by sudo.park on 2021/12/08.
//
//  DiscoveryScene
//
//  Created sudo.park on 2021/12/08.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Routing

public protocol AllSharedCollectionsRouting: Routing, Sendable {
    
    func switchToSharedCollection(_ collection: SharedReadCollection)
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias AllSharedCollectionsRouterBuildables = EmptyBuilder

public final class AllSharedCollectionsRouter: Router<AllSharedCollectionsRouterBuildables>, AllSharedCollectionsRouting {
    
    public weak var collectionMainInteractor: ReadCollectionMainSceneInteractable?
}


extension AllSharedCollectionsRouter {
    
    // AllSharedCollectionsRouting implements
    private var currentInteractor: AllSharedCollectionsSceneInteractable? {
        return (self.currentScene as? AllSharedCollectionsScene)?.interactor
    }
    
    public func switchToSharedCollection(_ collection: SharedReadCollection) {
        self.closeScene(animated: true) { [weak self] in
            self?.collectionMainInteractor?.switchToSharedCollection(collection)
        }
    }
}
