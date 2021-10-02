//
//  
//  ReadCollectionMainRouter.swift
//  ReadItemScene
//
//  Created by sudo.park on 2021/10/02.
//
//  ReadItemScene
//
//  Created sudo.park on 2021/10/02.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol ReadCollectionMainRouting: Routing {
    
    func setupSubCollections()
    
    func showSelectAddItemTypeScene()
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias ReadCollectionMainRouterBuildables = ReadCollectionItemSceneBuilable
    & SelectAddItemTypeSceneBuilable

public final class ReadCollectionMainRouter: Router<ReadCollectionMainRouterBuildables>, ReadCollectionMainRouting {
    
    private let bottomSliderTransitionManager = BottomSlideTransitionAnimationManager()
}


extension ReadCollectionMainRouter {
    
    public func setupSubCollections() {
        
        guard let current = self.currentScene as? UINavigationController,
              let nextScene = self.nextScenesBuilder?.makeReadCollectionItemScene(collectionID: nil) else {
            return
        }
        
        current.pushViewController(nextScene, animated: false)
    }
    
    public func showSelectAddItemTypeScene() {
        
        guard let next = self.nextScenesBuilder?.makeSelectAddItemTypeScene() else { return }
        next.modalPresentationStyle = .custom
        next.transitioningDelegate = self.bottomSliderTransitionManager
        next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
        self.currentScene?.present(next, animated: true, completion: nil)
    }
    
    private func getCurrentPresentingCollectionID() -> String? {
        return nil
    }
}
