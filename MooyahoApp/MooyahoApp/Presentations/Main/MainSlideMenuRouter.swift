//
//  
//  MainSlideMenuRouter.swift
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

import Domain
import CommonPresenting


// MARK: - Routing

public protocol MainSlideMenuRouting: Routing {
    
    func closeMenu()
    
    func setupDiscoveryScene()
    
    func editProfile()
    
    func openSetting()
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias MainSlideMenuRouterBuildables = EditProfileSceneBuilable & SettingMainSceneBuilable

public final class MainSlideMenuRouter: Router<MainSlideMenuRouterBuildables>, MainSlideMenuRouting { }


extension MainSlideMenuRouter {
    
    private var currentInteractor: MainSlideMenuSceneInteractor? {
        return (self.currentScene as? MainSlideMenuScene)?.interactor as? MainSlideMenuSceneInteractor
    }
    
    // MainSlideMenuRouting implements
    public func closeMenu() {
        self.currentScene?.dismiss(animated: true, completion: nil)
    }
    
    public func setupDiscoveryScene() {
        logger.todoImplement()
    }
    
    public func editProfile() {
        guard let next = self.nextScenesBuilder?.makeEditProfileScene() else { return }
        self.currentScene?.present(next, animated: true, completion: nil)
    }
    
    public func openSetting() {
        guard let next = self.nextScenesBuilder?
                .makeSettingMainScene(listener: self.currentInteractor)
        else {
            return
        }
        self.currentScene?.present(next, animated: true, completion: nil)
    }
}
