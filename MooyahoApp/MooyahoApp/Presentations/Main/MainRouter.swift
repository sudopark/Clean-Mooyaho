//
//  
//  MainRouter.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/05/20.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//
//  MooyahoApp
//
//  Created sudo.park on 2021/05/20.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol MainRouting: Routing { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias MainRouterBuildables = EmptyBuilder

public final class MainRouter: Router<MainRouterBuildables>, MainRouting { }


extension MainRouter {
    
    // MainRouting implements
}
