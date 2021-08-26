//
//  
//  HoorayDetailRouter.swift
//  HoorayScene
//
//  Created by sudo.park on 2021/08/26.
//
//  HoorayScene
//
//  Created sudo.park on 2021/08/26.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol HoorayDetailRouting: Routing { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias HoorayDetailRouterBuildables = EmptyBuilder

public final class HoorayDetailRouter: Router<HoorayDetailRouterBuildables>, HoorayDetailRouting { }


extension HoorayDetailRouter {
    
    // HoorayDetailRouting implements
}
