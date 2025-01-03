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

public protocol ReadCollectionMainRouting: Routing, Sendable {
    
    func setupSubCollections()
    
    func addNewColelctionAtCurrentCollection()
    
    func addNewReadLinkItemAtCurrentCollection()
    
    func addNewReadLinkItem(using url: String)
    
    func switchToMyReadCollection()
    
    func switchToSharedCollection(root: SharedReadCollection)
    
    func moveToRootCollection()
    
    func jumpToCollection(_ collectionID: String)
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias ReadCollectionMainRouterBuildables = ReadCollectionItemSceneBuilable & SharedCollectionItemsSceneBuilable

public final class ReadCollectionMainRouter: Router<ReadCollectionMainRouterBuildables>, ReadCollectionMainRouting  {
    
    public weak var navigationListener: ReadCollectionNavigateListenable?
    
    private var collectionInverseNavigationCoordinator: CollectionInverseNavigationCoordinator?
}


extension ReadCollectionMainRouter {
    
    public func setupSubCollections() {
        
        Task { @MainActor in
            guard let current = self.currentScene as? UINavigationController,
                  let nextScene = self.nextScenesBuilder?
                    .makeReadCollectionItemScene(collectionID: nil, navigationListener: self.navigationListener)
            else {
                return
            }
            
            current.viewControllers = [nextScene]
        }
    }
    
    public func switchToSharedCollection(root: SharedReadCollection) {
        Task { @MainActor in
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
    }
    
    public func switchToMyReadCollection() {
        self.setupSubCollections()
    }
    
    public func addNewColelctionAtCurrentCollection() {
        Task { @MainActor in
            guard let currentCollection = self.findCurrentCollectionScene() else { return }
            currentCollection.interactor?.addNewCollectionItem()
        }
    }
    
    public func addNewReadLinkItemAtCurrentCollection() {
        Task { @MainActor in
            guard let currentCollection = self.findCurrentCollectionScene() else { return }
            currentCollection.interactor?.addNewReadLinkItem()
        }
    }
    
    @MainActor
    private func findCurrentCollectionScene() -> ReadCollectionScene? {
        guard let childViewControllers = (self.currentScene as? BaseNavigationController)?.viewControllers else {
            return nil
        }
        let collectionScenes = childViewControllers.compactMap { $0 as? ReadCollectionScene }
        return collectionScenes.last
    }
    
    public func addNewReadLinkItem(using url: String) {
        Task { @MainActor in
            guard let currentCollection = self.findCurrentCollectionScene() else { return }
            currentCollection.interactor?.addNewReadLinkItem(using: url)
        }
    }
    
    public func moveToRootCollection() {
        Task { @MainActor in
            self.currentScene?.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    public func jumpToCollection(_ collectionID: String) {
        
        Task { @MainActor in
            self.prepareInverseCoordinatorIfNotExists()
            
            guard let navigationController = self.currentScene as? UINavigationController,
                  let root = self.nextScenesBuilder?
                    .makeReadCollectionItemScene(collectionID: nil, navigationListener: self.navigationListener),
                  let dest = self.nextScenesBuilder?
                    .makeReadCollectionItemScene(collectionID: collectionID,
                                                 navigationListener: self.navigationListener,
                                                 withInverse: self.collectionInverseNavigationCoordinator)
            else {
                return
            }
            
            navigationController.viewControllers = [root, dest]
        }
    }
    
    private func prepareInverseCoordinatorIfNotExists() {
        Task { @MainActor in
            guard self.collectionInverseNavigationCoordinator == nil else { return }
            let makeParent: (CollectionInverseParentMakeParameter) -> UIViewController?
            makeParent = { [weak self] parameter in
                guard let collectionID = parameter as? String else { return nil }
                
                let parent = self?.nextScenesBuilder?.makeReadCollectionItemScene(
                    collectionID: collectionID,
                    navigationListener: self?.navigationListener,
                    withInverse: self?.collectionInverseNavigationCoordinator
                )
                return parent
            }

            let navigation = self.currentScene as? UINavigationController
            self.collectionInverseNavigationCoordinator = .init(navigationController: navigation,
                                                                makeParent: makeParent)
        }
    }
}
