//
//  
//  ReadCollectionMainRouter.swift
//  ReadItemScene
//
//  Created by sudo.park on 2021/10/02.
//
//  ReadItemScene
//
//  Created sudo.park on 2021/10/02.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol ReadCollectionMainRouting: Routing {
    
    func setupSubCollections()
    
    func addNewColelctionAtCurrentCollection()
    
    func addNewReadLinkItemAtCurrentCollection()
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias ReadCollectionMainRouterBuildables = ReadCollectionItemSceneBuilable

public final class ReadCollectionMainRouter: Router<ReadCollectionMainRouterBuildables>, ReadCollectionMainRouting  { }


extension ReadCollectionMainRouter {
    
    public func setupSubCollections() {
        
        guard let current = self.currentScene as? UINavigationController,
              let nextScene = self.nextScenesBuilder?.makeReadCollectionItemScene(collectionID: nil) else {
            return
        }
        
        current.pushViewController(nextScene, animated: false)
    }
    
    public func addNewColelctionAtCurrentCollection() {
        guard let currentCollection = self.findCurrentCollectionScene() else { return }
        currentCollection.input?.addNewCollectionItem()
    }
    
    public func addNewReadLinkItemAtCurrentCollection() {
        guard let currentCollection = self.findCurrentCollectionScene() else { return }
        currentCollection.input?.addNewReadLinkItem()
    }
    
    private func findCurrentCollectionScene() -> ReadCollectionScene? {
        guard let childViewControllers = (self.currentScene as? BaseNavigationController)?.viewControllers else {
            return nil
        }
        let collectionScenes = childViewControllers.compactMap { $0 as? ReadCollectionScene }
        return collectionScenes.last
    }
}
