//
//  
//  MainSlideMenuBuilder.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/05/21.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//
//  MooyahoApp
//
//  Created sudo.park on 2021/05/21.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import RxSwift

import CommonPresenting


// MARK: - Builder + DI Container Extension

public protocol MainSlideMenuSceneBuilable {
    
    func makeMainSlideMenuScene() -> MainSlideMenuScene
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
