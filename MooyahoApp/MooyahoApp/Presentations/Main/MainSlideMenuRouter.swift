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

public protocol MainSlideMenuRouting: Routing, Sendable {
    
    func closeMenu()
    
    func setupDiscoveryScene()
    
    func editProfile()
    
    func openSetting()
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias MainSlideMenuRouterBuildables = EditProfileSceneBuilable & SettingMainSceneBuilable & DiscoveryMainSceneBuilable & MemberProfileSceneBuilable

public final class MainSlideMenuRouter: Router<MainSlideMenuRouterBuildables>, MainSlideMenuRouting {
    
    public weak var collectionMainInteractor: ReadCollectionMainSceneInteractable?
}


extension MainSlideMenuRouter {
    
    private var currentInteractor: MainSlideMenuSceneInteractor? {
        return (self.currentScene as? MainSlideMenuScene)?.interactor
    }
    
    // MainSlideMenuRouting implements
    public func closeMenu() {
        Task { @MainActor in
            self.currentScene?.dismiss(animated: true, completion: nil)
        }
    }
    
    public func setupDiscoveryScene() {
        Task { @MainActor in
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
    }
    
    public func editProfile() {
        Task { @MainActor in
            guard let next = self.nextScenesBuilder?.makeEditProfileScene() else { return }
            self.currentBaseViewControllerScene?.presentPageSheetOrFullScreen(next, animated: true)
        }
    }
    
    public func openSetting() {
        Task { @MainActor in
            guard let next = self.nextScenesBuilder?
                    .makeSettingMainScene(listener: self.currentInteractor)
            else {
                return
            }
            let navigtionController = BaseNavigationController(
                rootViewController: next,
                shouldHideNavigation: true,
                shouldShowCloseButtonIfNeed: false
            )
            self.currentBaseViewControllerScene?.presentPageSheetOrFullScreen(navigtionController, animated: true)
        }
    }
}


private extension CollectionRoot {
    
    var sharedCollectionShareID: String? {
        guard case let .sharedCollection(collection) = self else { return nil }
        return collection.shareID
    }
}
