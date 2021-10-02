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
import ReadItemScene


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


// MARK: - ReadItemScene

extension DependencyInjector: ReadCollectionMainSceneBuilable {
    
    public func makeReadCollectionMainScene() -> ReadCollectionMainScene {
        let router = ReadCollectionMainRouter(nextSceneBuilders: self)
        let viewModel = ReadCollectionMainViewModelImple(router: router)
        let viewController = ReadCollectionMainViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension DependencyInjector: ReadCollectionItemSceneBuilable {
    
    public func makeReadCollectionItemScene(collectionID: String?) -> ReadCollectionScene {
        let router = ReadCollectionItemsRouter(nextSceneBuilders: self)
        let viewModel = ReadCollectionViewItemsModelImple(collectionID: collectionID,
                                                     readItemUsecase: self.readItemUsecase,
                                                     router: router)
        let viewController = ReadCollectionItemsViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension DependencyInjector: AddReadLinkSceneBuilable {
    
    public func makeAddReadLinkScene(collectionID: String?,
                                     itemAddded: (() -> Void)?) -> AddReadLinkScene {
        let router = AddReadLinkRouter(nextSceneBuilders: self)
        let viewModel = AddReadLinkViewModelImple(collectionID: collectionID,
                                                  readItemUsecase: self.readItemUsecase,
                                                  router: router,
                                                  itemAddded: itemAddded)
        let viewController = AddReadLinkViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension DependencyInjector: SelectAddItemTypeSceneBuilable {
    
    public func makeSelectAddItemTypeScene(_ completed: @escaping (Bool) -> Void) -> SelectAddItemTypeScene {
        let router = SelectAddItemTypeRouter(nextSceneBuilders: self)
        let viewModel = SelectAddItemTypeViewModelImple(router: router, completed: completed)
        let viewController = SelectAddItemTypeViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}


// MARK: - EditReadItemScene

extension DependencyInjector: AddItemNavigationSceneBuilable {
    
    public func makeAddItemNavigationScene(at collectionID: String?,
                                           _ completed: @escaping (ReadLink) -> Void) -> AddItemNavigationScene {
        let router = AddItemNavigationRouter(nextSceneBuilders: self)
        let viewModel = AddItemNavigationViewModelImple(targetCollectionID: collectionID,
                                                        router: router)
        let viewController = AddItemNavigationViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}


extension DependencyInjector: EnterLinkURLSceneBuilable {
    
    public func makeEnterLinkURLScene(_ entered: @escaping (String) -> Void) -> EnterLinkURLScene {
        let router = EnterLinkURLRouter(nextSceneBuilders: self)
        let viewModel = EnterLinkURLViewModelImple(router: router)
        let viewController = EnterLinkURLViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

