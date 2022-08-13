//
//  
//  EnterLinkURLRouter.swift
//  EditReadItemScene
//
//  Created by sudo.park on 2021/10/02.
//
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/02.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol EnterLinkURLRouting: Routing, Sendable { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias EnterLinkURLRouterBuildables = EmptyBuilder

public final class EnterLinkURLRouter: Router<EnterLinkURLRouterBuildables>, EnterLinkURLRouting { }


extension EnterLinkURLRouter {
    
    // EnterLinkURLRouting implements
}
