//
//  
//  NavigateCollectionRouter.swift
//  ReadItemScene
//
//  Created by sudo.park on 2021/10/26.
//
//  ReadItemScene
//
//  Created sudo.park on 2021/10/26.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Routing

public protocol NavigateCollectionRouting: Routing {
    
    func moveToSubCollection(_ collection: ReadCollection)
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias NavigateCollectionRouterBuildables = NavigateCollectionSceneBuilable

public final class NavigateCollectionRouter: Router<NavigateCollectionRouterBuildables>, NavigateCollectionRouting { }


extension NavigateCollectionRouter {
    
    // NavigateCollectionRouting implements
    private var currentInteractor: NavigateCollectionSceneInteractable? {
        return (self.currentScene as? NavigateCollectionScene)?.interactor
    }
    
    public func moveToSubCollection(_ collection: ReadCollection) {
        
        guard let next = self.nextScenesBuilder?
                .makeNavigateCollectionScene(collection: collection, listener: nil)
        else { return }
        
        self.currentScene?.navigationController?.pushViewController(next, animated: true)
    }
}
