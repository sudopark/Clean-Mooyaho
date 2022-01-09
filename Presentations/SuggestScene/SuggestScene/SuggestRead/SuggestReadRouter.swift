
//
//  
//  SuggestReadRouter.swift
//  SuggestScene
//
//  Created by sudo.park on 2021/11/27.
//
//  SuggestScene
//
//  Created sudo.park on 2021/11/27.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Routing

public protocol SuggestReadRouting: Routing { 
    
    func showLinkDetail(_ linkID: String)
    
    func showAllFavoriteItemList()
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias SuggestReadRouterBuildables = InnerWebViewSceneBuilable & FavoriteItemsSceneBuilable

public final class SuggestReadRouter: Router<SuggestReadRouterBuildables>, SuggestReadRouting { }


extension SuggestReadRouter {
    
    // SuggestReadRouting implements
    private var currentInteractor: SuggestReadSceneInteractable? {
        return (self.currentScene as? SuggestReadScene)?.interactor
    }
    
    public func showLinkDetail(_ linkID: String) {
        
        guard let next = self.nextScenesBuilder?
                .makeInnerWebViewScene(linkID: linkID,
                                       isEditable: true,
                                       isJumpable: true,
                                       listener: self.currentInteractor)
        else {
            return
        }
        
        self.currentScene?.present(next, animated: true, completion: nil)
    }
    
    public func showAllFavoriteItemList() {
        
        guard let next = self.nextScenesBuilder?
                .makeFavoriteItemsScene(listener: self.currentInteractor)
        else {
            return
        }
        let navigationController = BaseNavigationController(rootViewController: next)
        navigationController.shouldHideNavigation = false
        self.currentScene?.present(navigationController, animated: true, completion: nil)
    }
}
