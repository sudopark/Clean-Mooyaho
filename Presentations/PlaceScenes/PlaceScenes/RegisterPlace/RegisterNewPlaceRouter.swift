//
//  
//  RegisterNewPlaceRouter.swift
//  PlaceScenes
//
//  Created by sudo.park on 2021/06/11.
//
//  PlaceScenes
//
//  Created sudo.park on 2021/06/11.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol RegisterNewPlaceRouting: Routing { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias RegisterNewPlaceRouterBuildables = EmptyBuilder

public final class RegisterNewPlaceRouter: Router<RegisterNewPlaceRouterBuildables>, RegisterNewPlaceRouting { }


extension RegisterNewPlaceRouter {
    
    // RegisterNewPlaceRouting implements
}
