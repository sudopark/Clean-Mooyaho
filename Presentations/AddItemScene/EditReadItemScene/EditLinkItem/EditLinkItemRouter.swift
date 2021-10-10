//
//  
//  EditLinkItemRouter.swift
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

public protocol EditLinkItemRouting: Routing {
    
    func requestRewind()
    
    func editPriority(startWith priority: ReadPriority?)
    
    func editCategory(startWith categories: [ItemCategory])
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias EditLinkItemRouterBuildables = EditReadPrioritySceneBuilable & EditCategorySceneBuilable

public final class EditLinkItemRouter: Router<EditLinkItemRouterBuildables>, EditLinkItemRouting {
    
    private let bottomSliderTransitionManager = BottomSlideTransitionAnimationManager()
}


extension EditLinkItemRouter {
    
    private var currentInteractor: EditLinkItemSceneInteractable? {
        return (self.currentScene as? EditLinkItemScene)?.interactor
    }
    
    // EditLinkItemRouting implements
    public func requestRewind() {
        
        guard let navigation = self.currentScene?.navigationController?.parent as? AddItemNavigationScene else {
            return
        }
        navigation.input?.requestpopToEnrerURLScene()
    }
    
    public func editPriority(startWith priority: ReadPriority?) {
        
        guard let next = self.nextScenesBuilder?
                .makeSelectPriorityScene(startWithSelected: priority, listener: self.currentInteractor) else {
            return
        }
        
        next.modalPresentationStyle = .custom
        next.transitioningDelegate = self.bottomSliderTransitionManager
        next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
        self.currentScene?.present(next, animated: true, completion: nil)
    }
    
    public func editCategory(startWith categories: [ItemCategory]) {
        
        guard let next = self.nextScenesBuilder?
                .makeEditCategoryScene(startWith: categories, listener: self.currentInteractor) else {
            return
        }
        self.currentScene?.present(next, animated: true, completion: nil)
    }
}
