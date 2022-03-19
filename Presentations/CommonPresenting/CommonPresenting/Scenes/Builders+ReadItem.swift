//
//  Builders+ReadItem.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/10/02.
//

import Foundation

import Domain


// MARK: - Builder + DependencyInjector Extension

public protocol NavigateCollectionSceneBuilable {
    
    func makeNavigateCollectionScene(
        collection: ReadCollection?,
        withoutSelect unselectableID: String?,
        listener: NavigateCollectionSceneListenable?,
        coordinator: CollectionInverseNavigationCoordinating?
    ) -> NavigateCollectionScene
}

extension NavigateCollectionSceneBuilable {
    
    public func makeNavigateCollectionScene(
        collection: ReadCollection?,
        withoutSelect unselectableID: String?,
        listener: NavigateCollectionSceneListenable?
    ) -> NavigateCollectionScene {
        
        return self.makeNavigateCollectionScene(
            collection: collection,
            withoutSelect: unselectableID,
            listener: listener,
            coordinator: nil
        )
    }
}


// MARK: - Builder + DependencyInjector Extension

public protocol FavoriteItemsSceneBuilable {
    
    func makeFavoriteItemsScene(listener: FavoriteItemsSceneListenable?) -> FavoriteItemsScene
}
