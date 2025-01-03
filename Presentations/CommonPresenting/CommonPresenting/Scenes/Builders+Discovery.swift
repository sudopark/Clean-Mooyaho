//
//  Builders+Discovery.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/11/14.
//

import UIKit

import Domain


// MARK: - Builder + DependencyInjector Extension

@MainActor
public protocol DiscoveryMainSceneBuilable {
    
    func makeDiscoveryMainScene(currentShareCollectionID: String?,
                                listener: DiscoveryMainSceneListenable?,
                                collectionMainInteractor: ReadCollectionMainSceneInteractable?) -> DiscoveryMainScene
}


// MARK: - Builder + DependencyInjector Extension

@MainActor
public protocol StopShareCollectionSceneBuilable {
    
    func makeStopShareCollectionScene(_ collectionID: String,
                                      listener: StopShareCollectionSceneListenable?) -> StopShareCollectionScene
}


// MARK: - Builder + DependencyInjector Extension

@MainActor
public protocol SharedCollectionItemsSceneBuilable {
    
    func makeSharedCollectionItemsScene(currentCollection: SharedReadCollection,
                                        listener: SharedCollectionItemsSceneListenable?,
                                        navigationListener: ReadCollectionNavigateListenable?) -> SharedCollectionItemsScene
}


// MARK: - Builder + DependencyInjector Extension

@MainActor
public protocol SharedCollectionInfoDialogSceneBuilable {
    
    func makeSharedCollectionInfoDialogScene(collection: SharedReadCollection,
                                             listener: SharedCollectionInfoDialogSceneListenable?) -> SharedCollectionInfoDialogScene
}
