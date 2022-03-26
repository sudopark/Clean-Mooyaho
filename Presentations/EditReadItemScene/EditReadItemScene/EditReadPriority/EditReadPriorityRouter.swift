//
//  
//  EditReadPriorityRouter.swift
//  EditReadItemScene
//
//  Created by sudo.park on 2021/10/04.
//
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/04.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol EditReadPriorityRouting: Routing { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias EditReadPriorityRouterBuildables = EmptyBuilder

public final class EditReadPriorityRouter: Router<EditReadPriorityRouterBuildables>, EditReadPriorityRouting { }


extension EditReadPriorityRouter {
    
    // EditReadPriorityRouting implements
    private var currentInteractor: EditReadPrioritySceneInteractable? {
        return (self.currentScene as? EditReadPriorityScene)?.interactor
    }
}
