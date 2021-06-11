//
//  
//  SearchNewPlaceRouter.swift
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

import Domain
import CommonPresenting


// MARK: - Routing

public protocol SearchNewPlaceRouting: Routing {
    
    func showPlaceDetail(_ placeID: String, link: String)
    
//    func showSelectPlaceCateTag()
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias SearchNewPlaceRouterBuildables = EmptyBuilder

public final class SearchNewPlaceRouter: Router<SearchNewPlaceRouterBuildables>, SearchNewPlaceRouting { }


extension SearchNewPlaceRouter {
    
    // SearchNewPlaceRouting implements
    public func showPlaceDetail(_ placeID: String, link: String) {
        logger.todoImplement()
    }
}
