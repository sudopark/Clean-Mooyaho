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

import CommonPresenting


// MARK: - Routing

public protocol MainSlideMenuRouting: Routing {
    
    func closeMenu()
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias MainSlideMenuRouterBuildables = EmptyBuilder

public final class MainSlideMenuRouter: Router<MainSlideMenuRouterBuildables>, MainSlideMenuRouting {
    
    public func closeMenu() {
        self.currentScene?.dismiss(animated: true, completion: nil)
    }
}


extension MainSlideMenuRouter {
    
    // MainSlideMenuRouting implements
}
