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

import Domain
import CommonPresenting


// MARK: - Routing

public protocol ReadCollectionMainRouting: Routing {
    
    func setupSubCollections()
    
    func addNewColelctionAtCurrentCollection()
    
    func addNewReadLinkItemAtCurrentCollection()
    
    func addNewReadLinkItem(using url: String)
    
    func switchToMyReadCollection()
    
    func switchToSharedCollection(root: SharedReadCollection)
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias ReadCollectionMainRouterBuildables = ReadCollectionItemSceneBuilable & SharedCollectionItemsSceneBuilable

public final class ReadCollectionMainRouter: Router<ReadCollectionMainRouterBuildables>, ReadCollectionMainRouting  {
    
    public weak var navigationListener: ReadCollectionNavigateListenable?
}


extension ReadCollectionMainRouter {
    
    public func setupSubCollections() {
        
        guard let current = self.currentScene as? UINavigationController,
              let nextScene = self.nextScenesBuilder?
                .makeReadCollectionItemScene(collectionID: nil, navigationListener: self.navigationListener)
        else {
            return
        }
        
        current.viewControllers = [nextScene]
    }
    
    public func switchToSharedCollection(root: SharedReadCollection) {
        guard let current = self.currentScene as? UINavigationController,
              let sharedRoot = self.nextScenesBuilder?
                .makeSharedCollectionItemsScene(currentCollection: root,
                                                listener: nil,
                                                navigationListener: self.navigationListener)
        else {
            return
        }
        current.viewControllers = [sharedRoot]
    }
    
    public func switchToMyReadCollection() {
        self.setupSubCollections()
    }
    
    public func addNewColelctionAtCurrentCollection() {
        guard let currentCollection = self.findCurrentCollectionScene() else { return }
        currentCollection.interactor?.addNewCollectionItem()
    }
    
    public func addNewReadLinkItemAtCurrentCollection() {
        guard let currentCollection = self.findCurrentCollectionScene() else { return }
        currentCollection.interactor?.addNewReadLinkItem()
    }
    
    private func findCurrentCollectionScene() -> ReadCollectionScene? {
        guard let childViewControllers = (self.currentScene as? BaseNavigationController)?.viewControllers else {
            return nil
        }
        let collectionScenes = childViewControllers.compactMap { $0 as? ReadCollectionScene }
        return collectionScenes.last
    }
    
    public func addNewReadLinkItem(using url: String) {
        guard let currentCollection = self.findCurrentCollectionScene() else { return }
        currentCollection.interactor?.addNewReadLinkItem(using: url)
    }
}
