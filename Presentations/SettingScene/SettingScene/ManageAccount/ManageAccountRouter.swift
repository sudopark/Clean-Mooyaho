//
//  
//  ManageAccountRouter.swift
//  SettingScene
//
//  Created by sudo.park on 2021/12/06.
//
//  SettingScene
//
//  Created sudo.park on 2021/12/06.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol ManageAccountRouting: Routing { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias ManageAccountRouterBuildables = EmptyBuilder

public final class ManageAccountRouter: Router<ManageAccountRouterBuildables>, ManageAccountRouting { }


extension ManageAccountRouter {
    
    // ManageAccountRouting implements
    private var currentInteractor: ManageAccountSceneInteractable? {
        return (self.currentScene as? ManageAccountScene)?.interactor
    }
}
