//
//  RootRouter.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit


public protocol ApplicationRootRouting: Routing {
    
    func routeMain()
}

// MARK: - builders

public typealias ApplicationRootRouterBuildings = MainTabSceneBuilable

// MARK: - Router

public final class ApplicationRootRouter: Router<ApplicationRootRouterBuildings>, ApplicationRootRouting {
    

    private var window: UIWindow!
}


extension ApplicationRootRouter {
    
    public func routeMain() {
        
        guard let main = self.nextSceneBuilders?.makeMainTabScene() else { return }
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window.rootViewController = main
        self.window.makeKeyAndVisible()
    }
}
