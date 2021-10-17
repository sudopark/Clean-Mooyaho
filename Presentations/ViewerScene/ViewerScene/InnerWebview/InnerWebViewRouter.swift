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
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias InnerWebViewRouterBuildables = EditLinkItemSceneBuilable

public final class InnerWebViewRouter: Router<InnerWebViewRouterBuildables>, InnerWebViewRouting {
    
    private let bottomSliderTransitionManager = BottomSlideTransitionAnimationManager()
}


extension InnerWebViewRouter {
    
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
}
