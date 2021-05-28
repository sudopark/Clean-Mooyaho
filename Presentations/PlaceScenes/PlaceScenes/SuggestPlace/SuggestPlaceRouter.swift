//
//  
//  SuggestPlaceRouter.swift
//  PlaceScenes
//
//  Created by sudo.park on 2021/05/28.
//
//  PlaceScenes
//
//  Created sudo.park on 2021/05/28.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol SuggestPlaceRouting: Routing { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias SuggestPlaceRouterBuildables = EmptyBuilder

public final class SuggestPlaceRouter: Router<SuggestPlaceRouterBuildables>, SuggestPlaceRouting { }


extension SuggestPlaceRouter {
    
    // SuggestPlaceRouting implements
}
