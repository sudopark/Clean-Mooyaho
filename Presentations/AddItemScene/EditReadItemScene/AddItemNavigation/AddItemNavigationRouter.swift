//
//  
//  AddItemNavigationRouter.swift
//  AddItemScene
//
//  Created by sudo.park on 2021/10/02.
//
//  AddItemScene
//
//  Created sudo.park on 2021/10/02.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol AddItemNavigationRouting: Routing { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias AddItemNavigationRouterBuildables = EmptyBuilder

public final class AddItemNavigationRouter: Router<AddItemNavigationRouterBuildables>, AddItemNavigationRouting { }


extension AddItemNavigationRouter {
    
    // AddItemNavigationRouting implements
}
