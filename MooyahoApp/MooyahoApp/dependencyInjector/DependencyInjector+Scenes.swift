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
import MapScenes
import MemberScenes
import PlaceScenes
import HoorayScene


// MARK: - Main Sceens

extension DependencyInjector: MainSceneBuilable {
    
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

extension DependencyInjector: MainSlideMenuSceneBuilable {
    
    public func makeMainSlideMenuScene() -> MainSlideMenuScene {
        let router = MainSlideMenuRouter(nextSceneBuilders: self)
        let viewModel = MainSlideMenuViewModelImple(router: router)
        let viewController = MainSlideMenuViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}


// MARK: - MemberScenes

extension DependencyInjector: SignInSceneBuilable, EditProfileSceneBuilable {
    
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

extension DependencyInjector: NearbySceneBuilable {
    
    public func makeNearbyScene() -> NearbyScene {
        let router = NearbyRouter(nextSceneBuilders: self)
        let viewModel = NearbyViewModelImple(locationUsecase: self.userLocationUsecase,
                                             hoorayUsecase: self.hoorayUsecase,
                                             memberUsecase: self.memberUsecase,
                                             router: router)
        let viewController = NearbyViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension DependencyInjector: LocationSelectSceneBuilable {
    
    public func makeLocationSelectScene(_ previousInfo: Location?) -> LocationSelectScene {
        let router = LocationSelectRouter(nextSceneBuilders: self)
        let viewModel = LocationSelectViewModelImple(previousInfo,
                                                     userLocationUsecase: self.userLocationUsecase,
                                                     router: router)
        let viewController = LocationSelectViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}


extension DependencyInjector: LocationMarkSceneBuilable {
    
    public func makeLocationMarkScene() -> LocationMarkScene {
        let router = LocationMarkRouter(nextSceneBuilders: self)
        let viewModel = LocationMarkViewModelImple(router: router)
        let viewController = LocationMarkViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}


// MARK: Place Scenes

extension DependencyInjector: SearchNewPlaceSceneBuilable {
    
    public func makeSearchNewPlaceScene(myID: String) -> SearchNewPlaceScene {
        let router = SearchNewPlaceRouter(nextSceneBuilders: self)
        let viewModel = SearchNewPlaceViewModelImple(userID: myID,
                                                     searchServiceProvider: self.searchServiceProvider,
                                                     userLocationUsecase: self.userLocationUsecase,
                                                     searchNewPlaceUsecase: self.searchNewPlaceUsecase,
                                                     registerNewPlaceUsecase: self.registerNewPlaceUsecase,
                                                     router: router)
        let viewController = SearchNewPlaceViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}


extension DependencyInjector: ManuallyResigterPlaceSceneBuilable {
    
    public func makeManuallyResigterPlaceScene(myID: String) -> ManuallyResigterPlaceScene {
        let router = ManuallyResigterPlaceRouter(nextSceneBuilders: self)
        let viewModel = ManuallyResigterPlaceViewModelImple(userID: myID,
                                                            userLocationUsecase: self.userLocationUsecase,
                                                            registerUsecase: self.registerNewPlaceUsecase,
                                                            router: router)
        let viewController = ManuallyResigterPlaceViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}



// MARK: - Hooray Scenes

extension DependencyInjector: MakeHooraySceneBuilable, WaitNextHooraySceneBuilable {
    
    public func makeMakeHoorayScene() -> MakeHoorayScene {
        let router = MakeHoorayRouter(nextSceneBuilders: self)
        let viewModel = MakeHoorayViewModelImple(memberUsecase: self.memberUsecase,
                                                 userLocationUsecase: self.userLocationUsecase,
                                                 hoorayPublishUsecase: self.hoorayUsecase,
                                                 permissionService: self.imagePickPermissionCheckService,
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
    
    public func makeEnterHoorayTagScene(form: NewHoorayForm) -> EnterHoorayTagScene {
        
        let router = EnterHoorayTagRouter(nextSceneBuilders: self)
        let viewModel = EnterHoorayTagViewModelImple(form: form, router: router)
        let viewController = EnterHoorayTagViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
    
    public func makeSelectHoorayPlaceScene(form: NewHoorayForm) -> SelectHoorayPlaceScene {
        
        let router = SelectHoorayPlaceRouter(nextSceneBuilders: self)
        let viewModel = SelectHoorayPlaceViewModelImple(form: form,
                                                        userLocationUsecase: self.userLocationUsecase,
                                                        suggestPlaceUsecase: self.suggestPlaceUsecase,
                                                        router: router)
        let viewController = SelectHoorayPlaceViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}


// MARK: - Common Scene

extension DependencyInjector: ImagePickerSceneBuilable {
    
    public func makeImagePickerScene(isCamera: Bool) -> ImagePickerScene {
        let viewController = SimpleImagePickerViewController()
        viewController.sourceType = isCamera ? .camera : .photoLibrary
        viewController.allowsEditing = true
        return viewController
    }
}

extension DependencyInjector: SelectTagSceneBuilable {
    
    public func makeSelectTagScene(startWith tags: [Tag], total: [Tag]) -> SelectTagScene {
        let router = SelectTagRouter(nextSceneBuilders: self)
        let viewModel = SelectTagViewModelImple(startWith: tags, total: total, router: router)
        let viewController = SelectTagViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension DependencyInjector: TextInputSceneBuilable {
    
    public func makeTextInputScene(_ inputMode: TextInputMode) -> TextInputScene {
        let router = TextInputRouter(nextSceneBuilders: self)
        let viewModel = TextInputViewModelImple(inputMode: inputMode,
                                                router: router)
        let viewController = TextInputViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}
