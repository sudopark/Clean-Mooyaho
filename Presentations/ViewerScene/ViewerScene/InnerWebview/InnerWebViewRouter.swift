//
//  
//  InnerWebViewRouter.swift
//  ViewerScene
//
//  Created by sudo.park on 2021/10/04.
//
//  ViewerScene
//
//  Created sudo.park on 2021/10/04.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Routing

public protocol InnerWebViewRouting: Routing {
    
    func openSafariBrowser(_ address: String)
    
    func editReadLink(_ item: ReadLink)
    
    func editMemo(_ memo: ReadLinkMemo)
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias InnerWebViewRouterBuildables = EditLinkItemSceneBuilable & LinkMemoSceneBuilable

public final class InnerWebViewRouter: Router<InnerWebViewRouterBuildables>, InnerWebViewRouting {
    
    private let bottomSliderTransitionManager = BottomSlideTransitionAnimationManager()
}


extension InnerWebViewRouter {
    
    private var currentSceneInteractor: InnerWebViewSceneInteractable? {
        return (self.currentScene as? InnerWebViewScene)?.interactor
    }
    
    // InnerWebViewRouting implements
    public func openSafariBrowser(_ address: String) {
        
        guard let url = URL(string: address) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    public func editReadLink(_ item: ReadLink) {
        guard let next = self.nextScenesBuilder?
                .makeEditLinkItemScene(.edit(item: item), collectionID: item.parentID, listener: nil)
        else { return }
        
        next.modalPresentationStyle = .custom
        next.transitioningDelegate = self.bottomSliderTransitionManager
        next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
        self.currentScene?.present(next, animated: true, completion: nil)
    }
    
    public func editMemo(_ memo: ReadLinkMemo) {
        
        guard let next = self.nextScenesBuilder?
                .makeLinkMemoScene(memo: memo, listener: self.currentSceneInteractor)
        else { return }
        
        next.modalPresentationStyle = .custom
        next.transitioningDelegate = self.bottomSliderTransitionManager
        next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
        self.currentScene?.present(next, animated: true, completion: nil)
    }
}
