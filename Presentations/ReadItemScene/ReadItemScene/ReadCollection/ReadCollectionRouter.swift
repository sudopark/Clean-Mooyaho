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

import Domain
import CommonPresenting


// MARK: - Routing

public protocol ReadCollectionRouting: Routing {
    
    func showItemSortOrderOptions(_ currentOrder: ReadCollectionItemSortOrder,
                                  selectedHandler: @escaping (ReadCollectionItemSortOrder) -> Void)
    
    func moveToSubCollection(collectionID: String)
    
    func showLinkDetail(_ linkID: String)
    
    func routeToMakeNewCollectionScene(_ completedHandler: @escaping (ReadCollection) -> Void)
    
    func routeToAddNewLink(at collectionID: String,
                           _ completionHandler: @escaping (ReadLink) -> Void)
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias ReadCollectionRouterBuildables = EmptyBuilder

public final class ReadCollectionRouter: Router<ReadCollectionRouterBuildables>, ReadCollectionRouting { }


extension ReadCollectionRouter {
    
    public func showItemSortOrderOptions(_ currentOrder: ReadCollectionItemSortOrder,
                                         selectedHandler: @escaping (ReadCollectionItemSortOrder) -> Void) {
        logger.todoImplement()
    }
    
    public func moveToSubCollection(collectionID: String) {
        logger.todoImplement()
    }
    
    public func showLinkDetail(_ linkID: String) {
        logger.todoImplement()
    }
    
    public func routeToMakeNewCollectionScene(_ completedHandler: @escaping (ReadCollection) -> Void) {
        logger.todoImplement()
    }
    
    public func routeToAddNewLink(at collectionID: String,
                                  _ completionHandler: @escaping (ReadLink) -> Void) {
        logger.todoImplement()
    }
}
