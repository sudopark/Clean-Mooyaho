//
//  
//  ColorSelectRouter.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/10/11.
//
//  CommonPresenting
//
//  Created sudo.park on 2021/10/11.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit


// MARK: - Routing

public protocol ColorSelectRouting: Routing { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias ColorSelectRouterBuildables = EmptyBuilder

public final class ColorSelectRouter: Router<ColorSelectRouterBuildables>, ColorSelectRouting { }


extension ColorSelectRouter {
    
    // ColorSelectRouting implements
    private var currentInteractor: ColorSelectSceneInteractable? {
        return (self.currentScene as? ColorSelectScene)?.interactor
    }
}
