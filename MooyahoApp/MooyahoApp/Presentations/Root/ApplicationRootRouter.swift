//
//  RootRouter.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


public protocol ApplicationRootRouting: Routing {
    
    func routeMain(auth: Auth)
}

// MARK: - builders

public typealias ApplicationRootRouterBuildables = MainSceneBuilable

// MARK: - Router

public final class ApplicationRootRouter: Router<ApplicationRootRouterBuildables>, ApplicationRootRouting {

    private var window: UIWindow!
}


extension ApplicationRootRouter {
    
    public func routeMain(auth: Auth) {
        
        guard let main = self.nextScenesBuilder?.makeMainScene(auth: auth) else { return }
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window.rootViewController = main
        self.window.makeKeyAndVisible()
    }
}
