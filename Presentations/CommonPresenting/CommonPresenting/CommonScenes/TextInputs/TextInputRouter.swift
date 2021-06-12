//
//  
//  TextInputRouter.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/12.
//
//  CommonPresenting
//
//  Created sudo.park on 2021/06/12.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit


// MARK: - Routing

public protocol TextInputRouting: Routing { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias TextInputRouterBuildables = EmptyBuilder

public final class TextInputRouter: Router<TextInputRouterBuildables>, TextInputRouting { }


extension TextInputRouter {
    
    // TextInputRouting implements
}
