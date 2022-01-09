//
//  
//  EditReadCollectionRouter.swift
//  EditReadItemScene
//
//  Created by sudo.park on 2021/10/03.
//
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/03.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Routing

public protocol EditReadCollectionRouting: Routing {
    
    func selectPriority(startWith: ReadPriority?)
    
    func selectCategories(startWith: [ItemCategory])
    
    func updateRemind(_ editCase: EditRemindCase)
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias EditReadCollectionRouterBuildables = EditReadPrioritySceneBuilable & EditCategorySceneBuilable & EditReadRemindSceneBuilable

public final class EditReadCollectionRouter: Router<EditReadCollectionRouterBuildables>, EditReadCollectionRouting {
    
    private let bottomSliderTransitionManager = BottomSlideTransitionAnimationManager()
}


extension EditReadCollectionRouter {
    
    // EditReadCollectionRouting implements
    private var currentInteractor: EditReadCollectionSceneInteractable? {
        return (self.currentScene as? EditReadCollectionScene)?.interactor
    }
    
    public func selectPriority(startWith: ReadPriority?) {
        
        guard let next = self.nextScenesBuilder?
                .makeSelectPriorityScene(startWithSelected: startWith,
                                         listener: self.currentInteractor) else {
            return
        }
        next.modalPresentationStyle = .custom
        next.transitioningDelegate = self.bottomSliderTransitionManager
        next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
        self.currentScene?.present(next, animated: true, completion: nil)
    }
    
    public func selectCategories(startWith: [ItemCategory]) {
        
        guard let next = self.nextScenesBuilder?.makeEditCategoryScene(
            startWith: startWith,
            listener: self.currentInteractor)
        else {
            return
        }
        self.currentScene?.present(next, animated: true, completion: nil)
    }
    
    public func updateRemind(_ editCase: EditRemindCase) {
            
        guard let next = self.nextScenesBuilder?
                .makeEditReadRemindScene(editCase, listener: self.currentInteractor)
        else { return }
        next.modalPresentationStyle = .custom
        next.transitioningDelegate = self.bottomSliderTransitionManager
        next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
        self.currentScene?.present(next, animated: true, completion: nil)
    }
}
