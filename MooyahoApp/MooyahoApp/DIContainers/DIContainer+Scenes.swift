//
//  DIContainer+Scenes.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/05/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import CommonPresenting
import LocationScenes


// MARK: - Main Sceens

extension DIContainers: MainSceneBuilable {
    
    public func makeMainScene() -> MainScene {
        let router = MainRouter(nextSceneBuilders: self)
        let viewModel = MainViewModelImple(router: router)
        let viewController = MainViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension DIContainers: MainSlideMenuSceneBuilable {
    
    public func makeMainSlideMenuScene() -> MainSlideMenuScene {
        let router = MainSlideMenuRouter(nextSceneBuilders: self)
        let viewModel = MainSlideMenuViewModelImple(router: router)
        let viewController = MainSlideMenuViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

// MARK: - Location Scenes

extension DIContainers: NearbySceneBuilable {
    
    public func makeNearbyScene(_ eventSignal: @escaping EventSignal<NearbySceneEvents>) -> NearbyScene {
        let router = NearbyRouter(nextSceneBuilders: self)
        let viewModel = NearbyViewModelImple(locationUsecase: self.userLocationUsecase,
                                             router: router,
                                             eventSignal: eventSignal)
        let viewController = NearbyViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}
