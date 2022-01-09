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


// MARK: - Main Sceens

extension DependencyInjector: MainSceneBuilable {
    
    public func makeMainScene(auth: Auth) -> MainScene {
        
        let itemUsecase = self.readItemUsecaseImple
        let router = MainRouter(nextSceneBuilders: self)
        let viewModel = MainViewModelImple(authUsecase: self.authUsecase,
                                           memberUsecase: self.memberUsecase,
                                           readItemOptionUsecase: itemUsecase,
                                           addItemSuggestUsecase: itemUsecase,
                                           shareCollectionUsecase: self.shareItemUsecase,
                                           router: router)
        let viewController = MainViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension DependencyInjector: MainSlideMenuSceneBuilable {
    
    public func makeMainSlideMenuScene(listener: MainSlideMenuSceneListenable?,
                                       collectionMainInteractor: ReadCollectionMainSceneInteractable?) -> MainSlideMenuScene {
        let router = MainSlideMenuRouter(nextSceneBuilders: self)
        let viewModel = MainSlideMenuViewModelImple(memberUsecase: self.memberUsecase,
                                                    router: router,
                                                    listener: listener)
        let viewController = MainSlideMenuViewController(viewModel: viewModel)
        router.currentScene = viewController
        router.collectionMainInteractor = collectionMainInteractor
        return viewController
    }
}


// MARK: - Common Scene

extension DependencyInjector: ImagePickerSceneBuilable {
    
    public func makeImagePickerScene(isCamera: Bool,
                                     listener: ImagePickerSceneListenable?) -> ImagePickerScene {
        let viewController = SimpleImagePickerViewController()
        viewController.sourceType = isCamera ? .camera : .photoLibrary
        viewController.allowsEditing = true
        viewController.listener = listener
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
    
    public func makeTextInputScene(_ inputMode: TextInputMode,
                                   listener: TextInputSceneListenable?) -> TextInputScene {
        let router = TextInputRouter(nextSceneBuilders: self)
        let viewModel = TextInputViewModelImple(inputMode: inputMode,
                                                router: router,
                                                listener: listener)
        let viewController = TextInputViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension DependencyInjector: ColorSelectSceneBuilable {
    
    public func makeColorSelectScene(_ dependency: SelectColorDepedency,
                                     listener: ColorSelectSceneListenable?) -> ColorSelectScene {
        let router = ColorSelectRouter(nextSceneBuilders: self)
        let viewModel = ColorSelectViewModelImple(startWithSelect: dependency.startWithSelect,
                                                  colorSources: dependency.colorSources,
                                                  router: router, listener: listener)
        let viewController = ColorSelectViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension DependencyInjector: SelectEmojiSceneBuilable {
    
    public func makeSelectEmojiScene(listener: SelectEmojiSceneListenable?) -> SelectEmojiScene {
        let viewController = SelectEmojiViewController()
        viewController.listener = listener
        return viewController
    }
}
