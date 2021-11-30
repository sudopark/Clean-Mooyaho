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
    
    func makeNavigateCollectionScene(collection: ReadCollection?,
                                     listener: NavigateCollectionSceneListenable?) -> NavigateCollectionScene
}


// MARK: - Builder + DependencyInjector Extension

public protocol FavoriteItemsSceneBuilable {
    
    func makeFavoriteItemsScene(listener: FavoriteItemsSceneListenable?) -> FavoriteItemsScene
}
