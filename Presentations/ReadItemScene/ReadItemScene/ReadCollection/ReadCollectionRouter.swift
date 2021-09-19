//
//  
//  ReadCollectionRouter.swift
//  ReadItemScene
//
//  Created by sudo.park on 2021/09/19.
//
//  ReadItemScene
//
//  Created sudo.park on 2021/09/19.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol ReadCollectionRouting: Routing { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias ReadCollectionRouterBuildables = EmptyBuilder

public final class ReadCollectionRouter: Router<ReadCollectionRouterBuildables>, ReadCollectionRouting { }


extension ReadCollectionRouter {
    
    // ReadCollectionRouting implements
}
