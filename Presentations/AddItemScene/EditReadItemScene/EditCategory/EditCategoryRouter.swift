//
//  
//  EditCategoryRouter.swift
//  EditReadItemScene
//
//  Created by sudo.park on 2021/10/08.
//
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/08.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol EditCategoryRouting: Routing {
    
    func showColorPicker(startWith select: String?, sources: [String])
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias EditCategoryRouterBuildables = ColorSelectSceneBuilable

public final class EditCategoryRouter: Router<EditCategoryRouterBuildables>, EditCategoryRouting {
    
    private let bottomSliderTransitionManager = BottomSlideTransitionAnimationManager()
}


extension EditCategoryRouter {
    
    // EditCategoryRouting implements
    private var currentInteractor: EditCategorySceneInteractable? {
        return (self.currentScene as? EditCategoryScene)?.interactor
    }
    
    public func showColorPicker(startWith select: String?, sources: [String]) {
        let dependency = SelectColorDepedency(startWithSelect: select, colorSources: sources)
        guard let next = self.nextScenesBuilder?.makeColorSelectScene(dependency, listener: self.currentInteractor) else {
            return
        }
        
        next.modalPresentationStyle = .custom
        next.transitioningDelegate = self.bottomSliderTransitionManager
        next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
        self.currentScene?.present(next, animated: true, completion: nil)
    }
}
