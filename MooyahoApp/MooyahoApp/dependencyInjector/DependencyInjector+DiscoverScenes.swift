//
//  DependencyInjector+DiscoverScenes.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/12/11.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting
import DiscoveryScene


// MARK: - DiscoveryScenes

extension DependencyInjector: DiscoveryMainSceneBuilable {
    
    public func makeDiscoveryMainScene(currentShareCollectionID: String?,
                                       listener: DiscoveryMainSceneListenable?,
                                       collectionMainInteractor: ReadCollectionMainSceneInteractable?) -> DiscoveryMainScene {
        let router = DiscoveryMainRouter(nextSceneBuilders: self)
        let viewModel = DiscoveryMainViewModelImple(currentSharedCollectionShareID: currentShareCollectionID,
                                                    sharedReadCollectionLoadUsecase: self.shareItemUsecase,
                                                    memberUsecase: self.memberUsecase,
                                                    router: router, listener: listener)
        let viewController = DiscoveryMainViewController(viewModel: viewModel)
        router.currentScene = viewController
        router.collectionMainInteractor = collectionMainInteractor
        return viewController
    }
}

extension DependencyInjector: StopShareCollectionSceneBuilable {
    
    public func makeStopShareCollectionScene(_ collectionID: String,
                                             listener: StopShareCollectionSceneListenable?) -> StopShareCollectionScene {
        let router = StopShareCollectionRouter(nextSceneBuilders: self)
        let viewModel = StopShareCollectionViewModelImple(shareURLScheme: AppEnvironment.shareScheme,
                                                          collectionID: collectionID,
                                                          shareCollectionUsecase: self.shareItemUsecase,
                                                          router: router, listener: nil)
        let viewController = StopShareCollectionViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension DependencyInjector: SharedCollectionItemsSceneBuilable {
    
    public func makeSharedCollectionItemsScene(currentCollection: SharedReadCollection,
                                               listener: SharedCollectionItemsSceneListenable?,
                                               navigationListener: ReadCollectionNavigateListenable?) -> SharedCollectionItemsScene {
        
        let itemsUsecase = self.readItemUsecase
        let router = SharedCollectionItemsRouter(nextSceneBuilders: self)
        router.navigationListener = navigationListener
        let viewModel = SharedCollectionItemsViewModelImple(currentCollection: currentCollection,
                                                            loadSharedCollectionUsecase: self.shareItemUsecase,
                                                            linkPreviewLoadUsecase: itemsUsecase,
                                                            readItemOptionsUsecase: itemsUsecase,
                                                            categoryUsecase: self.categoryUsecase,
                                                            router: router,
                                                            listener: nil,
                                                            navigationListener: navigationListener)
        let viewController = SharedCollectionItemsViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension DependencyInjector: SharedCollectionInfoDialogSceneBuilable {
    
    public func makeSharedCollectionInfoDialogScene(collection: SharedReadCollection,
                                                    listener: SharedCollectionInfoDialogSceneListenable?) -> SharedCollectionInfoDialogScene {
        let router = SharedCollectionInfoDialogRouter(nextSceneBuilders: self)
        let viewModel = SharedCollectionInfoDialogViewModelImple(collection: collection,
                                                                 shareItemsUsecase: self.shareItemUsecase,
                                                                 memberUsecase: self.memberUsecase,
                                                                 router: router,
                                                                 listener: listener)
        let viewController = SharedCollectionInfoDialogViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension DependencyInjector: AllSharedCollectionsSceneBuilable {
    
    func makeAllSharedCollectionsScene(
        listener: AllSharedCollectionsSceneListenable?,
        collectionMainInteractor: ReadCollectionMainSceneInteractable?
    ) -> AllSharedCollectionsScene {
        
        let router = AllSharedCollectionsRouter(nextSceneBuilders: self)
        router.collectionMainInteractor = collectionMainInteractor
        let viewModel = AllSharedCollectionsViewModelImple(
            pagingUsecase: self.sharedCollectionPagingUsecase,
            updateUsecase: self.shareItemUsecase,
            memberUsecase: self.memberUsecase,
            categoryUsecase: self.categoryUsecase,
            router: router, listener: listener
        )
        let viewController = AllSharedCollectionsViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}
