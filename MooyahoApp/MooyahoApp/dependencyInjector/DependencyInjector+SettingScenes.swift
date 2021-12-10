//
//  DependencyInjector+SettingScenes.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/12/11.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting
import SettingScene


// MARK: - SettingScenes

extension DependencyInjector: SettingMainSceneBuilable {
    
    public func makeSettingMainScene(listener: SettingMainSceneListenable?) -> SettingMainScene {
        let router = SettingMainRouter(nextSceneBuilders: self)
        let viewModel = SettingMainViewModelImple(memberUsecase: self.memberUsecase,
                                                  router: router, listener: listener)
        let viewController = SettingMainViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}


extension DependencyInjector: WaitMigrationSceneBuilable {
    
    public func makeWaitMigrationScene(userID: String,
                                       shouldResume: Bool,
                                       listener: WaitMigrationSceneListenable?) -> WaitMigrationScene {
        let router = WaitMigrationRouter(nextSceneBuilders: self)
        let viewModel = WaitMigrationViewModelImple(userID: userID,
                                                    shouldResume: shouldResume,
                                                    migrationUsecase: self.userDataMigrationUsecase,
                                                    router: router,
                                                    listener: listener)
        let viewController = WaitMigrationViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}


extension DependencyInjector: ManageCategorySceneBuilable {
    
    public func makeManageCategoryScene(listener: ManageCategorySceneListenable?) -> ManageCategoryScene {
        let router = ManageCategoryRouter(nextSceneBuilders: self)
        let viewModel = ManageCategoryViewModelImple(
            categoryUsecase: self.categoryUsecase,
            router: router,
            listener: listener
        )
        let viewController = ManageCategoryViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension DependencyInjector: EditCategoryAttrSceneBuilable {
    
    public func makeEditCategoryAttrScene(category: ItemCategory,
                                          listener: EditCategoryAttrSceneListenable?) -> EditCategoryAttrScene {
        let router = EditCategoryAttrRouter(nextSceneBuilders: self)
        let viewModel = EditCategoryAttrViewModelImple(
            category: category,
            categoryUsecase: self.categoryUsecase,
            router: router,
            listener: listener
        )
        let viewController = EditCategoryAttrViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension DependencyInjector: ManageAccountSceneBuilable {
    
    public func makeManageAccountScene(listener: ManageAccountSceneListenable?) -> ManageAccountScene {
        let router = ManageAccountRouter(nextSceneBuilders: self)
        let viewModel = ManageAccountViewModelImple(
            authUsecase: self.authUsecase,
            router: router,
            listener: listener
        )
        let viewController = ManageAccountViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}
