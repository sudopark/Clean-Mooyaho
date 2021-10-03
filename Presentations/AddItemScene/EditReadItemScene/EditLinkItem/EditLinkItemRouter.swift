//
//  
//  EditLinkItemRouter.swift
//  EditReadItemScene
//
//  Created by sudo.park on 2021/10/03.
//
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/03.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol EditLinkItemRouting: Routing {
    
    func requestRewind()
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias EditLinkItemRouterBuildables = EmptyBuilder

public final class EditLinkItemRouter: Router<EditLinkItemRouterBuildables>, EditLinkItemRouting { }


extension EditLinkItemRouter {
    
    // EditLinkItemRouting implements
    public func requestRewind() {
        
        guard let navigation = self.currentScene?.navigationController as? AddItemNavigationScene else {
            return
        }
        navigation.input?.requestpopToEnrerURLScene()
    }
}
