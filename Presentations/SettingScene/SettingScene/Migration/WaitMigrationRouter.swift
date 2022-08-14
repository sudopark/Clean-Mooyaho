//
//  
//  WaitMigrationRouter.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/11/07.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//
//  MooyahoApp
//
//  Created sudo.park on 2021/11/07.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol WaitMigrationRouting: Routing, Sendable { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias WaitMigrationRouterBuildables = EmptyBuilder

public final class WaitMigrationRouter: Router<WaitMigrationRouterBuildables>, WaitMigrationRouting { }


extension WaitMigrationRouter {
    
    // WaitMigrationRouting implements
    private var currentInteractor: WaitMigrationSceneInteractable? {
        return (self.currentScene as? WaitMigrationScene)?.interactor
    }
}
