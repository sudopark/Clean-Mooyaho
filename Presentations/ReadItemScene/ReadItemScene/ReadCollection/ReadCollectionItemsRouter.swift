//
//  
//  ReadCollectionRouter.swift
//  ReadItemScene
//
//  Created by sudo.park on 2021/09/19.
//
//  ReadItemScene
//
//  Created sudo.park on 2021/09/19.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Routing

public protocol ReadCollectionRouting: Routing {
    
    func showItemSortOrderOptions(_ currentOrder: ReadCollectionItemSortOrder,
                                  selectedHandler: @escaping (ReadCollectionItemSortOrder) -> Void)
    
    func moveToSubCollection(collectionID: String)
    
    func showLinkDetail(_ linkID: String)
    
    func routeToMakeNewCollectionScene(at collectionID: String?,
                                       _ completedHandler: @escaping (ReadCollection) -> Void)
    
    func routeToAddNewLink(at collectionID: String?,
                           _ completionHandler: @escaping (ReadLink) -> Void)
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias ReadCollectionRouterBuildables = AddItemNavigationSceneBuilable & EditReadCollectionSceneBuilable & ReadCollectionItemSceneBuilable

public final class ReadCollectionItemsRouter: Router<ReadCollectionRouterBuildables>, ReadCollectionRouting {
    
    private let bottomSliderTransitionManager = BottomSlideTransitionAnimationManager()
}


extension ReadCollectionItemsRouter {
    
    public func showItemSortOrderOptions(_ currentOrder: ReadCollectionItemSortOrder,
                                         selectedHandler: @escaping (ReadCollectionItemSortOrder) -> Void) {
        logger.todoImplement()
    }
    
    public func moveToSubCollection(collectionID: String) {
        
        guard let next = self.nextScenesBuilder?.makeReadCollectionItemScene(collectionID: collectionID) else {
            return
        }
        self.currentScene?.navigationController?.pushViewController(next, animated: true)
    }
    
    public func showLinkDetail(_ linkID: String) {
        logger.todoImplement()
    }
    
    public func routeToMakeNewCollectionScene(at collectionID: String?,
                                              _ completedHandler: @escaping (ReadCollection) -> Void) {
        
        guard let next = self.nextScenesBuilder?
                .makeEditReadCollectionScene(parentID: collectionID,
                                             editCase: .makeNew, completed: completedHandler) else {
            return
        }
        next.modalPresentationStyle = .custom
        next.transitioningDelegate = self.bottomSliderTransitionManager
        next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
        self.currentScene?.present(next, animated: true, completion: nil)
    }
    
    public func routeToAddNewLink(at collectionID: String?,
                                  _ completionHandler: @escaping (ReadLink) -> Void) {
        guard let next = self.nextScenesBuilder?
                .makeAddItemNavigationScene(at: collectionID, completionHandler) else {
            return
        }
        next.modalPresentationStyle = .custom
        next.transitioningDelegate = self.bottomSliderTransitionManager
        next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
        self.currentScene?.present(next, animated: true, completion: nil)
    }
}
