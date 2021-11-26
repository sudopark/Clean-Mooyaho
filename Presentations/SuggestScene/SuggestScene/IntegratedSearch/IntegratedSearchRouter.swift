//
//  
//  IntegratedSearchRouter.swift
//  SuggestScene
//
//  Created by sudo.park on 2021/11/23.
//
//  SuggestScene
//
//  Created sudo.park on 2021/11/23.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Routing

public protocol IntegratedSearchRouting: Routing {
    
    func setupSuggestScene() -> SuggestQuerySceneInteractable?
    
    func showLinkDetail(_ linkID: String)
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias IntegratedSearchRouterBuildables = SuggestQuerySceneBuilable & InnerWebViewSceneBuilable

public final class IntegratedSearchRouter: Router<IntegratedSearchRouterBuildables>, IntegratedSearchRouting {
    
    public weak var suggestQueryUsecase: SuggestQueryUsecase?
}


extension IntegratedSearchRouter {
    
    // IntegratedSearchRouting implements
    private var currentInteractor: IntegratedSearchSceneInteractable? {
        return (self.currentScene as? IntegratedSearchScene)?.interactor
    }
    
    public func setupSuggestScene() -> SuggestQuerySceneInteractable? {
        
        guard let searchScene = self.currentScene as? IntegratedSearchScene,
              let usecase = self.suggestQueryUsecase,
              let next = self.nextScenesBuilder?
                .makeSuggestQueryScene(suggestQueryUsecase:usecase,
                                       listener: self.currentInteractor)
        else {
            return nil
        }
        
        next.view.frame = CGRect(origin: .zero, size: searchScene.suggestSceneContainer.frame.size)
        next.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        searchScene.addChild(next)
        searchScene.suggestSceneContainer.addSubview(next.view)
        next.didMove(toParent: searchScene)
        
        return next.interactor
    }
    
    public func showLinkDetail(_ linkID: String) {
        
        // TOOD:
    }
}
