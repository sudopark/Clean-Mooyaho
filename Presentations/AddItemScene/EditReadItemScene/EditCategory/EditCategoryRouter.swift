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

public protocol EditCategoryRouting: Routing { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias EditCategoryRouterBuildables = EmptyBuilder

public final class EditCategoryRouter: Router<EditCategoryRouterBuildables>, EditCategoryRouting { }


extension EditCategoryRouter {
    
    // EditCategoryRouting implements
    private var currentInteractor: EditCategorySceneInteractable? {
        return (self.currentScene as? EditCategoryScene)?.interactor
    }
}
