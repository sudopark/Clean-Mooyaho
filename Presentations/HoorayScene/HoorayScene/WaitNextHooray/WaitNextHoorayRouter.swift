//
//  
//  WaitNextHoorayRouter.swift
//  HoorayScene
//
//  Created by sudo.park on 2021/06/06.
//
//  HoorayScene
//
//  Created sudo.park on 2021/06/06.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol WaitNextHoorayRouting: Routing { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias WaitNextHoorayRouterBuildables = EmptyBuilder

public final class WaitNextHoorayRouter: Router<WaitNextHoorayRouterBuildables>, WaitNextHoorayRouting { }


extension WaitNextHoorayRouter {
    
    // WaitNextHoorayRouting implements
}
