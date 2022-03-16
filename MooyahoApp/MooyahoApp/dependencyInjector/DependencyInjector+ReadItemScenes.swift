//
//  DependencyInjector+ReadItemScenes.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/12/11.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting
import ReadItemScene


// MARK: - ReadItemScene

extension DependencyInjector: ReadCollectionMainSceneBuilable {
    
    public func makeReadCollectionMainScene(navigationListener: ReadCollectionNavigateListenable?) -> ReadCollectionMainScene {
        let router = ReadCollectionMainRouter(nextSceneBuilders: self)
        let viewModel = ReadCollectionMainViewModelImple(router: router, navigationListener: navigationListener)
        let viewController = ReadCollectionMainViewController(viewModel: viewModel)
        router.currentScene = viewController
        router.navigationListener = navigationListener
        return viewController
    }
}

extension DependencyInjector: ReadCollectionItemSceneBuilable {
    
    public func makeReadCollectionItemScene(collectionID: String?,
                                            navigationListener: ReadCollectionNavigateListenable?,
                                            withInverse coordinator: CollectionInverseNavigationCoordinating?) -> ReadCollectionScene {
        let router = ReadCollectionItemsRouter(nextSceneBuilders: self)
        let usecase = self.readItemUsecaseImple
        let viewModel = ReadCollectionViewItemsModelImple(collectionID: collectionID,
                                                          readItemUsecase: usecase,
                                                          favoriteUsecase: usecase,
                                                          categoryUsecase: self.categoryUsecase,
                                                          readItemSyncUsecase: usecase,
                                                          remindUsecase: usecase,
                                                          router: router,
                                                          navigationListener: navigationListener,
                                                          inverseNavigationCoordinating: coordinator)
        let viewController = ReadCollectionItemsViewController(viewModel: viewModel)
        router.currentScene = viewController
        router.navigationListener = navigationListener
        return viewController
    }
}


extension DependencyInjector: NavigateCollectionSceneBuilable {
    
    public func makeNavigateCollectionScene(
        collection: ReadCollection?,
        listener: NavigateCollectionSceneListenable?,
        coordinator: CollectionInverseNavigationCoordinating?
    ) -> NavigateCollectionScene {
        
        let router = NavigateCollectionRouter(nextSceneBuilders: self)
        let viewModel = NavigateCollectionViewModelImple(currentCollection: collection,
                                                         readItemUsecase: self.readItemUsecase,
                                                         router: router,
                                                         listener: listener,
                                                         coordinator: coordinator)
        let viewController = NavigateCollectionViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension DependencyInjector: FavoriteItemsSceneBuilable {
    
    public func makeFavoriteItemsScene(listener: FavoriteItemsSceneListenable?) -> FavoriteItemsScene {
        
        let router = FavoriteItemsRouter(nextSceneBuilders: self)
        
        let readUsecase = self.readItemUsecase
        let pagingUsecase = FavoriteItemsPagingUsecaseImple(favoriteItemsUsecase: readUsecase,
                                                            itemsLoadUsecase: readUsecase)
        
        let viewModel = FavoriteItemsViewModelImple(
            pagingUsecase: pagingUsecase,
            previewLoadUsecase: readUsecase,
            categoryUsecase: self.categoryUsecase,
            router: router,
            listener: listener
        )
        let viewController = FavoriteItemsViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}
