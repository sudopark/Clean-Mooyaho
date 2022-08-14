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

public protocol DiscoveryMainRouting: Routing, Sendable {
    
    func viewAllSharedCollections()
    
    func routeToSharedCollection(_ collection: SharedReadCollection)
    
    func routeToMyReadCollection()
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias DiscoveryMainRouterBuildables = AllSharedCollectionsSceneBuilable

public final class DiscoveryMainRouter: Router<DiscoveryMainRouterBuildables>, DiscoveryMainRouting {
    
    public weak var collectionMainInteractor: ReadCollectionMainSceneInteractable?
}


extension DiscoveryMainRouter {
    
    // DiscoveryMainRouting implements
    private var currentInteractor: DiscoveryMainSceneInteractable? {
        return (self.currentScene as? DiscoveryMainScene)?.interactor
    }
    
    public func viewAllSharedCollections() {
        
        Task { @MainActor in
            guard let next = self.nextScenesBuilder?
                    .makeAllSharedCollectionsScene(listener: nil,
                                                   collectionMainInteractor: self.collectionMainInteractor)
            else {
                return
            }
            let navigationController = BaseNavigationController(
                rootViewController: next,
                shouldHideNavigation: false,
                shouldShowCloseButtonIfNeed: true
            )
            self.currentBaseViewControllerScene?.presentPageSheetOrFullScreen(navigationController, animated: true)
        }
    }
    
    public func routeToSharedCollection(_ collection: SharedReadCollection) {
        self.collectionMainInteractor?.switchToSharedCollection(collection)
    }
    
    public func routeToMyReadCollection() {
        self.collectionMainInteractor?.switchToMyReadCollections()
    }
}
