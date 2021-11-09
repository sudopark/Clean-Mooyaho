//
//  
//  MainSlideMenuRouter.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/05/21.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//
//  MooyahoApp
//
//  Created sudo.park on 2021/05/21.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Routing

public protocol MainSlideMenuRouting: Routing {
    
    func closeMenu()
    
    func setupDiscoveryScene()
    
    func editProfile()
    
    func startDiscover()
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias MainSlideMenuRouterBuildables = EmptyBuilder

public final class MainSlideMenuRouter: Router<MainSlideMenuRouterBuildables>, MainSlideMenuRouting {
    
    public func closeMenu() {
        self.currentScene?.dismiss(animated: true, completion: nil)
    }
    
    public func setupDiscoveryScene() {
        logger.todoImplement()
    }
    
    public func editProfile() {
        logger.todoImplement()
    }
    
    public func startDiscover() {
        logger.todoImplement()
    }
}


extension MainSlideMenuRouter {
    
    // MainSlideMenuRouting implements
}
