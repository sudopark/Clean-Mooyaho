//
//  
//  SelectAddItemTypeRouter.swift
//  ReadItemScene
//
//  Created by sudo.park on 2021/10/02.
//
//  ReadItemScene
//
//  Created sudo.park on 2021/10/02.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol SelectAddItemTypeRouting: Routing, Sendable { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias SelectAddItemTypeRouterBuildables = EmptyBuilder

public final class SelectAddItemTypeRouter: Router<SelectAddItemTypeRouterBuildables>, SelectAddItemTypeRouting { }


extension SelectAddItemTypeRouter {
}
