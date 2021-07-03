//
//  
//  SelectHoorayPlaceRouter.swift
//  HoorayScene
//
//  Created by sudo.park on 2021/06/08.
//
//  HoorayScene
//
//  Created sudo.park on 2021/06/08.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol SelectHoorayPlaceRouting: Routing {
    
    func presentNewPlaceRegisterScene(myID: String) -> SearchNewPlaceSceneOutput?
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias SelectHoorayPlaceRouterBuildables = SearchNewPlaceSceneBuilable

public final class SelectHoorayPlaceRouter: Router<SelectHoorayPlaceRouterBuildables>, SelectHoorayPlaceRouting { }


extension SelectHoorayPlaceRouter {
    
    public func presentNewPlaceRegisterScene(myID: String) -> SearchNewPlaceSceneOutput? {
        
        guard let next = self.nextScenesBuilder?.makeSearchNewPlaceScene(myID: myID) else { return nil }
        self.currentScene?.present(next, animated: true, completion: nil)
        return next.output
    }
}
