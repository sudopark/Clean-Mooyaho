//
//  DependencyInjector+EditReadItemScenes.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/12/11.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting
import EditReadItemScene


// MARK: - EditReadItemScene

extension DependencyInjector: SelectAddItemTypeSceneBuilable {
    
    public func makeSelectAddItemTypeScene(_ completed: @escaping (Bool) -> Void) -> SelectAddItemTypeScene {
        let router = SelectAddItemTypeRouter(nextSceneBuilders: self)
        let viewModel = SelectAddItemTypeViewModelImple(router: router, completed: completed)
        let viewController = SelectAddItemTypeViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension DependencyInjector: AddItemNavigationSceneBuilable {
    
    public func makeAddItemNavigationScene(at collectionID: String?,
                                           startWith: String?,
                                           _ listener: AddItemNavigationSceneListenable?) -> AddItemNavigationScene {
        let router = AddItemNavigationRouter(nextSceneBuilders: self)
        let viewModel = AddItemNavigationViewModelImple(startWith: startWith,
                                                        targetCollectionID: collectionID,
                                                        router: router,
                                                        listener: listener)
        let viewController = AddItemNavigationViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}


extension DependencyInjector: EnterLinkURLSceneBuilable {
    
    public func makeEnterLinkURLScene(startWith: String?,
                                      _ entered: @escaping (String) -> Void) -> EnterLinkURLScene {
        let router = EnterLinkURLRouter(nextSceneBuilders: self)
        let viewModel = EnterLinkURLViewModelImple(startWith: startWith,
                                                   router: router, callback: entered)
        let viewController = EnterLinkURLViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}


extension DependencyInjector: EditLinkItemSceneBuilable {
    
    public func makeEditLinkItemScene(_ editCase: EditLinkItemCase,
                                      collectionID: String?,
                                      listener: EditLinkItemSceneListenable?) -> EditLinkItemScene {
        
        let router = EditLinkItemRouter(nextSceneBuilders: self)
        let viewModel = EditLinkItemViewModelImple(collectionID: collectionID,
                                                   editCase: editCase,
                                                   readUsecase: self.readItemUsecase,
                                                   categoryUsecase: self.categoryUsecase,
                                                   router: router,
                                                   listener: listener)
        let viewController = EditLinkItemViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension DependencyInjector: EditReadCollectionSceneBuilable {
    
    public func makeEditReadCollectionScene(parentID: String?,
                                            editCase: EditCollectionCase,
                                            listener: EditReadCollectionSceneListenable?) -> EditReadCollectionScene {
        
        let router = EditReadCollectionRouter(nextSceneBuilders: self)
        let viewModel = EditReadCollectionViewModelImple(parentID: parentID,
                                                         editCase: editCase,
                                                         updateUsecase: self.readItemUsecase,
                                                         categoriesUsecase: self.categoryUsecase,
                                                         remindUsecase: self.remindUsecase,
                                                         router: router,
                                                         listener: listener)
        let viewController = EditReadCollectionViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension DependencyInjector: EditReadPrioritySceneBuilable {
    
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

extension DependencyInjector: EditCategorySceneBuilable {
    
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


extension DependencyInjector: EditItemsCustomOrderSceneBuilable {
    
    public func makeEditItemsCustomOrderScene(collectionID: String?,
                                              listener: EditItemsCustomOrderSceneListenable?) -> EditItemsCustomOrderScene {
        let router = EditItemsCustomOrderRouter(nextSceneBuilders: self)
        let viewModel = EditItemsCustomOrderViewModelImple(collectionID: collectionID,
                                                           readItemUsecase: self.readItemUsecase,
                                                           router: router,
                                                           listener: listener)
        let viewController = EditItemsCustomOrderViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}


extension DependencyInjector: EditReadRemindSceneBuilable {
    
    public func makeEditReadRemindScene(_ editCase: EditRemindCase,
                                        listener: EditReadRemindSceneListenable?) -> EditReadRemindScene {
        let router = EditReadRemindRouter(nextSceneBuilders: self)
        let viewModel = EditReadRemindViewModelImple(editCase,
                                                     remindUsecase: self.remindUsecase,
                                                     router: router, listener: listener)
        let viewController = EditReadRemindViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}
