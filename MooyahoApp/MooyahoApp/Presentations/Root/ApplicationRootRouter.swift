//
//  RootRouter.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import CommonPresenting


public protocol ApplicationRootRouting: Routing {
    
    func routeMain()
}

// MARK: - builders

public typealias ApplicationRootRouterBuildables = MainTabSceneBuilable

// MARK: - Router

public final class ApplicationRootRouter: Router<ApplicationRootRouterBuildables>, ApplicationRootRouting {

    private var window: UIWindow!
}


extension ApplicationRootRouter {
    
    public func routeMain() {
        
        guard let main = self.nextScenesBuilder?.makeMainTabScene() else { return }
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window.rootViewController = main
        self.window.makeKeyAndVisible()
    }
}
