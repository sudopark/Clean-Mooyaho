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

public protocol SharedCollectionItemsRouting: Routing, Sendable {
    
    func moveToSubCollection(collection: SharedReadCollection)
    
    func showLinkDetail(_ link: SharedReadLink)
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias SharedCollectionItemsRouterBuildables = SharedCollectionItemsSceneBuilable & InnerWebViewSceneBuilable

public final class SharedCollectionItemsRouter: Router<SharedCollectionItemsRouterBuildables>, SharedCollectionItemsRouting {
    
    public weak var navigationListener: ReadCollectionNavigateListenable?
}


extension SharedCollectionItemsRouter {
    
    // SharedCollectionItemsRouting implements
    private var currentInteractor: SharedCollectionItemsSceneInteractable? {
        return (self.currentScene as? SharedCollectionItemsScene)?.interactor
    }
    
    public func moveToSubCollection(collection: SharedReadCollection) {
        Task { @MainActor in
            guard let next = self.nextScenesBuilder?
                    .makeSharedCollectionItemsScene(currentCollection: collection,
                                                     listener: nil,
                                                     navigationListener: self.navigationListener)
            else {
                return
            }
            self.currentScene?.navigationController?.pushViewController(next, animated: true)
        }
    }
    
    public func showLinkDetail(_ link: SharedReadLink) {
        
        Task { @MainActor in
            guard let next = self.nextScenesBuilder?
                    .makeInnerWebViewScene(link: link.asReadLink(), isEditable: false,
                                           listener: nil) else { return }
            self.currentScene?.present(next, animated: true, completion: nil)
        }
    }
}
