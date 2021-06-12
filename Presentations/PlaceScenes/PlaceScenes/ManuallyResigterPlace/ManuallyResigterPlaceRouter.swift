//
//  
//  ManuallyResigterPlaceRouter.swift
//  PlaceScenes
//
//  Created by sudo.park on 2021/06/12.
//
//  PlaceScenes
//
//  Created sudo.park on 2021/06/12.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Routing

public protocol ManuallyResigterPlaceRouting: Routing {
    
    func addSmallMapView() -> LocationMarkSceneInteractor?
    
    func openPlaceTitleInputScene() -> TextInputScenePresenter?
    
    func openLocationSelectScene() -> LocationSelectScenePresenter?
    
    func openTagSelectScene() -> SelectTagScenePresenter?
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias ManuallyResigterPlaceRouterBuildables = EmptyBuilder

public final class ManuallyResigterPlaceRouter: Router<ManuallyResigterPlaceRouterBuildables>, ManuallyResigterPlaceRouting { }


extension ManuallyResigterPlaceRouter {
    
    public func addSmallMapView() -> LocationMarkSceneInteractor? {
        return nil
    }
    
    public func openPlaceTitleInputScene() -> TextInputScenePresenter? {
        return nil
    }
    
    public func openLocationSelectScene() -> LocationSelectScenePresenter? {
        return nil
    }
    
    public func openTagSelectScene() -> SelectTagScenePresenter? {
        return nil
    }
}
