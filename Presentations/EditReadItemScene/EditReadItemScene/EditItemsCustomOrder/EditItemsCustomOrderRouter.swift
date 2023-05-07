//
//  
//  EditItemsCustomOrderRouter.swift
//  EditReadItemScene
//
//  Created by sudo.park on 2021/10/15.
//
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/15.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol EditItemsCustomOrderRouting: Routing, Sendable { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias EditItemsCustomOrderRouterBuildables = EmptyBuilder

public final class EditItemsCustomOrderRouter: Router<EditItemsCustomOrderRouterBuildables>, EditItemsCustomOrderRouting { }


extension EditItemsCustomOrderRouter {
    
    // EditItemsCustomOrderRouting implements
    private var currentInteractor: EditItemsCustomOrderSceneInteractable? {
        return (self.currentScene as? EditItemsCustomOrderScene)?.interactor
    }
}
