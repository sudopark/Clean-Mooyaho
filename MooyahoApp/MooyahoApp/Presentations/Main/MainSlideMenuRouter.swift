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
public typealias MainSlideMenuRouterBuildables = EditProfileSceneBuilable & SettingMainSceneBuilable & DiscoveryMainSceneBuilable

public final class MainSlideMenuRouter: Router<MainSlideMenuRouterBuildables>, MainSlideMenuRouting {
    
    public weak var collectionMainInteractor: ReadCollectionMainSceneInteractable?
}


extension MainSlideMenuRouter {
    
    private var currentInteractor: MainSlideMenuSceneInteractor? {
        return (self.currentScene as? MainSlideMenuScene)?.interactor
    }
    
    // MainSlideMenuRouting implements
    public func closeMenu() {
        self.currentScene?.dismiss(animated: true, completion: nil)
    }
    
    public func setupDiscoveryScene() {
        let shareID = self.collectionMainInteractor?.rootType.sharedCollectionShareID
        guard let sliderScene = self.currentScene as? MainSlideMenuScene,
              let next = self.nextScenesBuilder?
                .makeDiscoveryMainScene(currentShareCollectionID: shareID,
                                        listener: self.currentInteractor,
                                        collectionMainInteractor: self.collectionMainInteractor)
        else {
            return
        }
        next.view.frame = CGRect(origin: .zero,
                                 size: sliderScene.discoveryContainerView.frame.size)
        next.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sliderScene.addChild(next)
        sliderScene.discoveryContainerView.addSubview(next.view)
        next.didMove(toParent: sliderScene)
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


private extension CollectionRoot {
    
    var sharedCollectionShareID: String? {
        guard case let .sharedCollection(collection) = self else { return nil }
        return collection.shareID
    }
}
