//
//  ApplicationRouter.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit


struct ApplicationRouter: Routable {
    
    typealias SceneDI = ApplicationDIContainer
    
    private var window: UIWindow
    private let diContainer: ApplicationDIContainer
    
    init(DI container: SceneDI) {
        self.diContainer = container
        self.window = UIWindow(frame: UIScreen.main.bounds)
    }
    
    func route(to scene: Scene, from context: Scenable?) {
        
        switch scene {
        case .launching:
            // TODO: make logo scene and replace and make visible
            break
            
        case let .mainTab(subScenes):
            // TOOD: make main tab and route
            break
            
        default: break
        }
    }
}
