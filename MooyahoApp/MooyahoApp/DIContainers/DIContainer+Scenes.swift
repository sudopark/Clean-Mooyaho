//
//  DIContainer+Scenes.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/05/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting
import MemberScenes
import LocationScenes
import PlaceScenes
import HoorayScene


// MARK: - Main Sceens

extension DIContainers: MainSceneBuilable {
    
    public func makeMainScene(auth: Auth) -> MainScene {
        let router = MainRouter(nextSceneBuilders: self)
        let viewModel = MainViewModelImple(memberUsecase: self.memberUsecase,
                                           hoorayUsecase: self.hoorayUsecase,
                                           router: router)
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


// MARK: - MemberScenes

extension DIContainers: SignInSceneBuilable, EditProfileSceneBuilable {
    
    public func makeSignInScene() -> SignInScene {
        let router = SignInRouter(nextSceneBuilders: self)
        let viewModel = SignInViewModelImple(authUsecase: self.authUsecase,
                                             router: router)
        let viewController = SignInViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
    
    public func makeEditProfileScene() -> EditProfileScene {
        let router = EditProfileRouter(nextSceneBuilders: self)
        let viewModel = EditProfileViewModelImple(usecase: self.memberUsecase,
                                                  router: router)
        let viewController = EditProfileViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}


// MARK: - Location Scenes

extension DIContainers: NearbySceneBuilable {
    
    public func makeNearbyScene() -> NearbyScene {
        let router = NearbyRouter(nextSceneBuilders: self)
        let viewModel = NearbyViewModelImple(locationUsecase: self.userLocationUsecase,
                                             router: router)
        let viewController = NearbyViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

// MARK: Place Scenes

extension DIContainers: SuggestPlaceSceneBuilable {

    public func makeSuggestPlaceScene() -> SuggestPlaceScene {
        let router = SuggestPlaceRouter(nextSceneBuilders: self)
        let viewModel = SuggestPlaceViewModelImple(router: router)
        let viewController = SuggestPlaceViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}


// MARK: - Hooray Scenes

extension DIContainers: MakeHooraySceneBuilable, WaitNextHooraySceneBuilable {
    
    public func makeMakeHoorayScene() -> MakeHoorayScene {
        let router = MakeHoorayRouter(nextSceneBuilders: self)
        let viewModel = MakeHoorayViewModelImple(memberUsecase: self.memberUsecase,
                                                 userLocationUsecase: self.userLocationUsecase,
                                                 hoorayPublishUsecase: self.hoorayUsecase,
                                                 router: router)
        let viewController = MakeHoorayViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
    
    public func makeWaitNextHoorayScene(_ waitUntil: TimeStamp) -> WaitNextHoorayScene {
        let router = WaitNextHoorayRouter(nextSceneBuilders: self)
        let viewModel = WaitNextHoorayViewModelImple(waitUntil: waitUntil, router: router)
        let viewController = WaitNextHoorayViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

