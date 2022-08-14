//
//  
//  ManageCategoryRouter.swift
//  SettingScene
//
//  Created by sudo.park on 2021/12/03.
//
//  SettingScene
//
//  Created sudo.park on 2021/12/03.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Routing

public protocol ManageCategoryRouting: Routing, Sendable {
    
    func moveToEditCategory(_ category: ItemCategory)
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias ManageCategoryRouterBuildables = EditCategoryAttrSceneBuilable

public final class ManageCategoryRouter: Router<ManageCategoryRouterBuildables>, ManageCategoryRouting {
    
    @MainActor private let bottomSliderTransitionManager = BottomSlideTransitionAnimationManager()
}


extension ManageCategoryRouter {
    
    // ManageCategoryRouting implements
    private var currentInteractor: ManageCategorySceneInteractable? {
        return (self.currentScene as? ManageCategoryScene)?.interactor
    }
    
    public func moveToEditCategory(_ category: ItemCategory) {
        
        Task { @MainActor in
            guard let next = self.nextScenesBuilder?
                    .makeEditCategoryAttrScene(category: category, listener: self.currentInteractor)
            else {
                return
            }
            
            next.modalPresentationStyle = .custom
            next.transitioningDelegate = self.bottomSliderTransitionManager
            self.currentScene?.present(next, animated: true, completion: nil)
        }
    }
}
