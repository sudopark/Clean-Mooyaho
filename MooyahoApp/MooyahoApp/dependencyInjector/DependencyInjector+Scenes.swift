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
import EditReadItemScene
import ViewerScene


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
                                                          categoryUsecase: self.categoryUsecase,
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
                                                        router: router,
                                                        completed)
        let viewController = AddItemNavigationViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}


extension DependencyInjector: EnterLinkURLSceneBuilable {
    
    public func makeEnterLinkURLScene(_ entered: @escaping (String) -> Void) -> EnterLinkURLScene {
        let router = EnterLinkURLRouter(nextSceneBuilders: self)
        let viewModel = EnterLinkURLViewModelImple(router: router, callback: entered)
        let viewController = EnterLinkURLViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}


extension DependencyInjector: EditLinkItemSceneBuilable {
    
    public func makeEditLinkItemScene(_ editCase: EditLinkItemCase,
                                      collectionID: String?,
                                      completed: @escaping (ReadLink) -> Void) -> EditLinkItemScene {
        
        let router = EditLinkItemRouter(nextSceneBuilders: self)
        let viewModel = EditLinkItemViewModelImple(collectionID: collectionID,
                                                   editCase: editCase,
                                                   readUsecase: self.readItemUsecase,
                                                   router: router,
                                                   completed: completed)
        let viewController = EditLinkItemViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension DependencyInjector: EditReadCollectionSceneBuilable {
    
    public func makeEditReadCollectionScene(parentID: String?,
                                            editCase: EditCollectionCase,
                                            completed: @escaping (ReadCollection) -> Void) -> EditReadCollectionScene {
        let router = EditReadCollectionRouter(nextSceneBuilders: self)
        let viewModel = EditReadCollectionViewModelImple(parentID: parentID,
                                                         editCase: editCase,
                                                         updateUsecase: self.readItemUsecase,
                                                         router: router,
                                                         completed: completed)
        let viewController = EditReadCollectionViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension DependencyInjector: EditReadPrioritySceneBuilable {
    
    public func makeSelectPriorityScene(startWithSelected: ReadPriority?,
                                        listener: ReadPrioritySelectListenable?) -> EditReadPriorityScene {
        let router = EditReadPriorityRouter(nextSceneBuilders: self)
        let viewModel = ReadPrioritySelectViewModelImple(startWithSelect: startWithSelected,
                                                         router: router,
                                                         listener: listener)
        let viewController = EditReadPriorityViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
    
    public func makeChangePriorityScene(for item: ReadItem,
                                        listener: ReadPriorityUpdateListenable?) -> EditReadPriorityScene {
        let router = EditReadPriorityRouter(nextSceneBuilders: self)
        let viewModel = ReadPriorityChangeViewModelImple(item: item,
                                                         updateUsecase: self.readItemUsecase,
                                                         router: router,
                                                         listener: listener)
        let viewController = EditReadPriorityViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension DependencyInjector: EditCategorySceneBuilable {
    
    public func makeEditCategoryScene(startWith select: [ItemCategory],
                                      listener: EditCategorySceneListenable?) -> EditCategoryScene {
        let router = EditCategoryRouter(nextSceneBuilders: self)
        let viewModel = EditCategoryViewModelImple(startWith: select,
                                                   categoryUsecase: self.categoryUsecase,
                                                   suggestUsecase: self.suggestCategoryUsecase,
                                                   router: router,
                                                   listener: listener)
        let viewController = EditCategoryViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}



// MARK: - ViewerScenes

extension DependencyInjector: InnerWebViewSceneBuilable {
    
    public func makeInnerWebViewScene(itemID: String) -> InnerWebViewScene {
        let router = InnerWebViewRouter(nextSceneBuilders: self)
        let viewModel = InnerWebViewViewModelImple(itemID: itemID,
                                                   readItemUsecase: self.readItemUsecase,
                                                   router: router)
        let viewController = InnerWebViewViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

