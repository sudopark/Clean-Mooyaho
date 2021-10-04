//
//  
//  InnerWebViewRouter.swift
//  ViewerScene
//
//  Created by sudo.park on 2021/10/04.
//
//  ViewerScene
//
//  Created sudo.park on 2021/10/04.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol InnerWebViewRouting: Routing { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias InnerWebViewRouterBuildables = EmptyBuilder

public final class InnerWebViewRouter: Router<InnerWebViewRouterBuildables>, InnerWebViewRouting { }


extension InnerWebViewRouter {
    
    // InnerWebViewRouting implements
}
