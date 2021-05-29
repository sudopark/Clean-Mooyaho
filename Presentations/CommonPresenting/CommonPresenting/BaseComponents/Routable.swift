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

public protocol Routing: AnyObject {
    
    func alertError(_ error: Error)
    
    func showToast(_ message: String)
}
extension Routing {
    
    public func alertError(_ error: Error) { }
    
    public func showToast(_ message: String) { }
}


open class Router<Buildables>: Routing {
    
    public final let nextScenesBuilder: Buildables?
    public weak var currentScene: Scenable?
    
    public init(nextSceneBuilders: Buildables) {
        self.nextScenesBuilder = nextSceneBuilders
    }
}



extension Router {
    
    public func alertError(_ error: Error) {
        print("☠️ should implement -> \(#function)")
    }
    
    public func showToast(_ message: String) {
        print("☠️ should implement -> \(#function)")
    }
}
