//
//  
//  LocationMarkRouter.swift
//  LocationScenes
//
//  Created by sudo.park on 2021/06/12.
//
//  LocationScenes
//
//  Created sudo.park on 2021/06/12.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol LocationMarkRouting: Routing { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias LocationMarkRouterBuildables = EmptyBuilder

public final class LocationMarkRouter: Router<LocationMarkRouterBuildables>, LocationMarkRouting { }


extension LocationMarkRouter {
    
    // LocationMarkRouting implements
}
