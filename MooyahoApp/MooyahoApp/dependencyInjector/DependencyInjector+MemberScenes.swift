//
//  DependencyInjector+MemberScenes.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/12/11.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting
import MemberScenes


// MARK: - MemberScenes

extension DependencyInjector: SignInSceneBuilable, EditProfileSceneBuilable {
    
    public func makeSignInScene(_ listener: SignInSceneListenable?) -> SignInScene {
        let router = SignInRouter(nextSceneBuilders: self)
        let viewModel = SignInViewModelImple(authUsecase: self.authUsecase,
                                             router: router,
                                             listener: listener)
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

extension DependencyInjector: MemberProfileSceneBuilable {
    
    public func makeMemberProfileScene(listener: MemberProfileSceneListenable?) -> MemberProfileScene {
        let router = MemberProfileRouter(nextSceneBuilders: self)
        let viewModel = MemberProfileViewModelImple(router: router, listener: listener)
        let viewController = MemberProfileViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

