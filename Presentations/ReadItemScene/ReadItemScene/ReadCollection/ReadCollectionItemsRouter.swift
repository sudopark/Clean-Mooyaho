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
    
    func showLinkDetail(_ link: ReadLink)
    
    func routeToMakeNewCollectionScene(at collectionID: String?)
    
    func routeToEditCollection(_ collection: ReadCollection)
    
    func routeToAddNewLink(at collectionID: String?)
    
    func routeToEditReadLink(_ link: ReadLink)
    
    func roueToEditCustomOrder(for collectionID: String?)
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias ReadCollectionRouterBuildables = AddItemNavigationSceneBuilable & EditReadCollectionSceneBuilable & ReadCollectionItemSceneBuilable & InnerWebViewSceneBuilable & EditLinkItemSceneBuilable & EditItemsCustomOrderSceneBuilable

public final class ReadCollectionItemsRouter: Router<ReadCollectionRouterBuildables>, ReadCollectionRouting {
    
    private let bottomSliderTransitionManager = BottomSlideTransitionAnimationManager()
}


extension ReadCollectionItemsRouter {
    
    private var currentInteractor: ReadCollectionItemsSceneInteractable? {
        return (self.currentScene as? ReadCollectionScene)?.interactor
    }
    
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
    
    public func showLinkDetail(_ link: ReadLink) {
        
        guard let next = self.nextScenesBuilder?.makeInnerWebViewScene(link: link) else {
            return
        }
        self.currentScene?.present(next, animated: true)
    }
    
    public func routeToMakeNewCollectionScene(at collectionID: String?) {
        
        guard let next = self.nextScenesBuilder?
                .makeEditReadCollectionScene(parentID: collectionID,
                                             editCase: .makeNew,
                                             listener: self.currentInteractor) else {
            return
        }
        next.modalPresentationStyle = .custom
        next.transitioningDelegate = self.bottomSliderTransitionManager
        next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
        self.currentScene?.present(next, animated: true, completion: nil)
    }
    
    public func routeToEditCollection(_ collection: ReadCollection) {
        guard let next = self.nextScenesBuilder?
                .makeEditReadCollectionScene(parentID: collection.parentID,
                                             editCase: .edit(collection),
                                             listener: self.currentInteractor) else {
            return
        }
        next.modalPresentationStyle = .custom
        next.transitioningDelegate = self.bottomSliderTransitionManager
        next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
        self.currentScene?.present(next, animated: true, completion: nil)
    }
    
    public func routeToAddNewLink(at collectionID: String?) {
        guard let next = self.nextScenesBuilder?
                .makeAddItemNavigationScene(at: collectionID, self.currentInteractor) else {
            return
        }
        next.modalPresentationStyle = .custom
        next.transitioningDelegate = self.bottomSliderTransitionManager
        next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
        self.currentScene?.present(next, animated: true, completion: nil)
    }
    
    public func routeToEditReadLink(_ link: ReadLink) {
        
        guard let next = self.nextScenesBuilder?.makeEditLinkItemScene(.edit(item: link),
                                                                       collectionID: link.parentID,
                                                                       listener: self.currentInteractor) else {
            return
        }
        
        next.modalPresentationStyle = .custom
        next.transitioningDelegate = self.bottomSliderTransitionManager
        next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
        self.currentScene?.present(next, animated: true, completion: nil)
    }
    
    public func roueToEditCustomOrder(for collectionID: String?) {
        
        guard let next = self.nextScenesBuilder?
                .makeEditItemsCustomOrderScene(collectionID: collectionID, listener: nil) else {
            return
        }
        
        self.currentScene?.present(next, animated: true, completion: nil)
    }
}
