//
//  
//  NearbyRouter.swift
//  MapScenes
//
//  Created by sudo.park on 2021/05/22.
//
//  MapScenes
//
//  Created sudo.park on 2021/05/22.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol NearbyRouting: Routing { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias NearbyRouterBuildables = EmptyBuilder

public final class NearbyRouter: Router<NearbyRouterBuildables>, NearbyRouting { }


extension NearbyRouter {
    
    // NearbyRouting implements
}
