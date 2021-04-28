//
//  
//  MainTabBuilder.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//
//  BreadRoadApp
//
//  Created ParkHyunsoo on 2021/04/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Builder + DI Container Extension

public protocol MainTabSceneBuilable {
    
    func makeMainTabScene() -> MainTabScene
}


extension DIContainers: MainTabSceneBuilable {
    
    public func makeMainTabScene() -> MainTabScene {
        let router = MainTabRouter(nextSceneBuilders: self)
        let viewModel = MainTabViewModelImple(router: router)
        let viewController = MainTabViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}
