//
//  
//  AllSharedCollectionsBuilder.swift
//  DiscoveryScene
//
//  Created by sudo.park on 2021/12/08.
//
//  DiscoveryScene
//
//  Created sudo.park on 2021/12/08.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Builder + DependencyInjector Extension

public protocol AllSharedCollectionsSceneBuilable {
    
    func makeAllSharedCollectionsScene(
        listener: AllSharedCollectionsSceneListenable?,
        collectionMainInteractor: ReadCollectionMainSceneInteractable?
    ) -> AllSharedCollectionsScene
}
