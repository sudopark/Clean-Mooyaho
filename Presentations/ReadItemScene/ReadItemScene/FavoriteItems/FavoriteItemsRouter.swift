//
//  
//  FavoriteItemsRouter.swift
//  ReadItemScene
//
//  Created by sudo.park on 2021/12/01.
//
//  ReadItemScene
//
//  Created sudo.park on 2021/12/01.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Routing

public protocol FavoriteItemsRouting: Routing {
    
    func showLinkDetail(_ link: ReadLink)
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias FavoriteItemsRouterBuildables = InnerWebViewSceneBuilable

public final class FavoriteItemsRouter: Router<FavoriteItemsRouterBuildables>, FavoriteItemsRouting { }


extension FavoriteItemsRouter {
    
    // FavoriteItemsRouting implements
    private var currentInteractor: FavoriteItemsSceneInteractable? {
        return (self.currentScene as? FavoriteItemsScene)?.interactor
    }
    
    public func showLinkDetail(_ link: ReadLink) {
        
        guard let next = self.nextScenesBuilder?
                .makeInnerWebViewScene(link: link, isEditable: true,
                                       isJumpable: true, listener: self.currentInteractor)
        else {
            return
        }
        self.currentScene?.present(next, animated: true, completion: nil)
    }
}
