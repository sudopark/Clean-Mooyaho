//
//  
//  AddReadLinkRouter.swift
//  ReadItemScene
//
//  Created by sudo.park on 2021/09/26.
//
//  ReadItemScene
//
//  Created sudo.park on 2021/09/26.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol AddReadLinkRouting: Routing { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias AddReadLinkRouterBuildables = EmptyBuilder

public final class AddReadLinkRouter: Router<AddReadLinkRouterBuildables>, AddReadLinkRouting { }


extension AddReadLinkRouter {
    
    // AddReadLinkRouting implements
}
