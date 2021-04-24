//
//  Routable.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import RxSwift

// MARK: Routing and Router

public protocol Routing: class { }

open class Router<Buildable>: Routing {
    
    public final let nextSceneBuilders: Buildable?
    public weak var currentScene: Scenable?
    
    public init(nextSceneBuilders: Buildable) {
        self.nextSceneBuilders = nextSceneBuilders
    }
    
    public init() where Buildable == EmptyBuilder {
        self.nextSceneBuilders = nil
    }
}
