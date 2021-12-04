//
//  
//  EditCategoryAttrRouter.swift
//  SettingScene
//
//  Created by sudo.park on 2021/12/04.
//
//  SettingScene
//
//  Created sudo.park on 2021/12/04.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol EditCategoryAttrRouting: Routing { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias EditCategoryAttrRouterBuildables = EmptyBuilder

public final class EditCategoryAttrRouter: Router<EditCategoryAttrRouterBuildables>, EditCategoryAttrRouting { }


extension EditCategoryAttrRouter {
    
    // EditCategoryAttrRouting implements
    private var currentInteractor: EditCategoryAttrSceneInteractable? {
        return (self.currentScene as? EditCategoryAttrScene)?.interactor
    }
}
