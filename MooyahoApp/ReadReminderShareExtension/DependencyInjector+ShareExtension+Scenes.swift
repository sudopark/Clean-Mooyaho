//
//  DependencyInjector+ShareExtension+Scenes.swift
//  ReadReminderShareExtension
//
//  Created by sudo.park on 2021/10/28.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import Domain
import CommonPresenting
import EditReadItemScene
import ReadItemScene


// MARK: - edit scenes

extension SharedDependencyInjecttor: EditLinkItemSceneBuilable {
    
    public func makeEditLinkItemScene(_ editCase: EditLinkItemCase,
                                      collectionID: String?,
                                      listener: EditLinkItemSceneListenable?) -> EditLinkItemScene {
        
        let router = EditLinkItemRouter(nextSceneBuilders: self)
        let usecase = self.readItemUsecase
        let viewModel = EditLinkItemViewModelImple(collectionID: collectionID,
                                                   editCase: editCase,
                                                   readUsecase: usecase,
                                                   remindUsecase: usecase,
                                                   categoryUsecase: self.categoryUsecase,
                                                   router: router,
                                                   listener: listener)
        let viewController = EditLinkItemViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension SharedDependencyInjecttor: EditReadPrioritySceneBuilable {
    
    public func makeSelectPriorityScene(startWithSelected: ReadPriority?,
                                        listener: ReadPrioritySelectListenable?) -> EditReadPriorityScene {
        let router = EditReadPriorityRouter(nextSceneBuilders: self)
        let viewModel = ReadPrioritySelectViewModelImple(startWithSelect: startWithSelected,
                                                         router: router,
                                                         listener: listener)
        let viewController = EditReadPriorityViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
    
    public func makeChangePriorityScene(for item: ReadItem,
                                        listener: ReadPriorityUpdateListenable?) -> EditReadPriorityScene {
        let router = EditReadPriorityRouter(nextSceneBuilders: self)
        let viewModel = ReadPriorityChangeViewModelImple(item: item,
                                                         updateUsecase: self.readItemUsecase,
                                                         router: router,
                                                         listener: listener)
        let viewController = EditReadPriorityViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension SharedDependencyInjecttor: EditCategorySceneBuilable {
    
    public func makeEditCategoryScene(startWith select: [ItemCategory],
                                      listener: EditCategorySceneListenable?) -> EditCategoryScene {
        let router = EditCategoryRouter(nextSceneBuilders: self)
        let viewModel = EditCategoryViewModelImple(startWith: select,
                                                   categoryUsecase: self.categoryUsecase,
                                                   suggestUsecase: self.suggestCategoryUsecase,
                                                   router: router,
                                                   listener: listener)
        let viewController = EditCategoryViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension SharedDependencyInjecttor: EditReadRemindSceneBuilable {
    
    public func makeEditReadRemindScene(_ editCase: EditRemindCase,
                                        listener: EditReadRemindSceneListenable?) -> EditReadRemindScene {
        let router = EditReadRemindRouter(nextSceneBuilders: self)
        let viewModel = EditReadRemindViewModelImple(editCase,
                                                     remindUsecase: self.readItemUsecase,
                                                     router: router, listener: listener)
        let viewController = EditReadRemindViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension SharedDependencyInjecttor: ColorSelectSceneBuilable {
    
    public func makeColorSelectScene(_ dependency: SelectColorDepedency,
                                     listener: ColorSelectSceneListenable?) -> ColorSelectScene {
        let router = ColorSelectRouter(nextSceneBuilders: self)
        let viewModel = ColorSelectViewModelImple(startWithSelect: dependency.startWithSelect,
                                                  colorSources: dependency.colorSources,
                                                  router: router, listener: listener)
        let viewController = ColorSelectViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}


// MARK: - items scene - navigation

extension SharedDependencyInjecttor: NavigateCollectionSceneBuilable {
    
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

