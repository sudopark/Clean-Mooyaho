//
//  Routable.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import RxSwift

import Domain

// MARK: Routing and Router

public protocol Routing: AnyObject {
    
    func alertError(_ error: Error)
    
    func showToast(_ message: String)
    
    func closeScene(animated: Bool)
}
extension Routing {
    
    public func alertError(_ error: Error) { }
    
    public func showToast(_ message: String) { }
    
    public func closeScene(animated: Bool) { }
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
        logger.todoImplement()
    }
    
    public func showToast(_ message: String) {
        logger.todoImplement()
    }
    
    public func closeScene(animated: Bool) {
        self.currentScene?.dismiss(animated: true, completion: nil)
    }
}
