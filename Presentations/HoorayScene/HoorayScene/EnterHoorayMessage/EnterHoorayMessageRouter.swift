//
//  
//  EnterHoorayMessageRouter.swift
//  HoorayScene
//
//  Created by sudo.park on 2021/06/07.
//
//  HoorayScene
//
//  Created sudo.park on 2021/06/07.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Routing

public protocol EnterHoorayMessageRouting: Routing { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias EnterHoorayMessageRouterBuildables = EmptyBuilder

public final class EnterHoorayMessageRouter: Router<EnterHoorayMessageRouterBuildables>, EnterHoorayMessageRouting { }


extension EnterHoorayMessageRouter {
  
}
