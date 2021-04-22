//
//  Routable.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public protocol Routable {
    
    associatedtype SceneDI: DIContainer
    
    init(DI container: SceneDI)
    
    func route(to scene: Scene, from context: Scenable?)
}
