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

public protocol ManageCategoryRouting: Routing {
    
    func moveToEditCategory(_ category: ItemCategory)
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias ManageCategoryRouterBuildables = EmptyBuilder

public final class ManageCategoryRouter: Router<ManageCategoryRouterBuildables>, ManageCategoryRouting { }


extension ManageCategoryRouter {
    
    // ManageCategoryRouting implements
    private var currentInteractor: ManageCategorySceneInteractable? {
        return (self.currentScene as? ManageCategoryScene)?.interactor
    }
    
    public func moveToEditCategory(_ category: ItemCategory) {
        
    }
}
