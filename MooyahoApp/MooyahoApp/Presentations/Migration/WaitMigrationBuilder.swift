//
//  
//  WaitMigrationBuilder.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/11/07.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//
//  MooyahoApp
//
//  Created sudo.park on 2021/11/07.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Builder + DependencyInjector Extension

public protocol WaitMigrationSceneBuilable {
    
    func makeWaitMigrationScene(userID: String,
                                listener: WaitMigrationSceneListenable?) -> WaitMigrationScene
}


extension DependencyInjector: WaitMigrationSceneBuilable {
    
    public func makeWaitMigrationScene(userID: String,
                                       listener: WaitMigrationSceneListenable?) -> WaitMigrationScene {
        let router = WaitMigrationRouter(nextSceneBuilders: self)
        let viewModel = WaitMigrationViewModelImple(userID: userID,
                                                    migrationUsecase: self.userDataMigrationUsecase,
                                                    router: router,
                                                    listener: listener)
        let viewController = WaitMigrationViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}
