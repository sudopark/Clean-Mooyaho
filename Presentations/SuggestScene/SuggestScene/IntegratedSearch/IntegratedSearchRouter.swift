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

import CommonPresenting


// MARK: - Routing

public protocol IntegratedSearchRouting: Routing {
    
    func setupSuggestScene() -> SuggestQuerySceneInteractable?
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias IntegratedSearchRouterBuildables = SuggestQuerySceneBuilable

public final class IntegratedSearchRouter: Router<IntegratedSearchRouterBuildables>, IntegratedSearchRouting { }


extension IntegratedSearchRouter {
    
    // IntegratedSearchRouting implements
    private var currentInteractor: IntegratedSearchSceneInteractable? {
        return (self.currentScene as? IntegratedSearchScene)?.interactor
    }
    
    public func setupSuggestScene() -> SuggestQuerySceneInteractable? {
        
        guard let searchScene = self.currentScene as? IntegratedSearchScene,
              let next = self.nextScenesBuilder?.makeSuggestQueryScene(listener: self.currentInteractor)
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
}
