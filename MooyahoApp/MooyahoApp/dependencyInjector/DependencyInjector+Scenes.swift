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
import SettingScene


// MARK: - Main Sceens

extension DependencyInjector: MainSceneBuilable {
    
    public func makeMainScene(auth: Auth) -> MainScene {
        
        let itemUsecase = self.readItemUsecaseImple
        let router = MainRouter(nextSceneBuilders: self)
        let viewModel = MainViewModelImple(memberUsecase: self.memberUsecase,
                                           readItemOptionUsecase: itemUsecase,
                                           addItemSuggestUsecase: itemUsecase,
                                           router: router)
        let viewController = MainViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension DependencyInjector: MainSlideMenuSceneBuilable {
    
    public func makeMainSlideMenuScene(listener: MainSlideMenuSceneListenable?) -> MainSlideMenuScene {
        let router = MainSlideMenuRouter(nextSceneBuilders: self)
        let viewModel = MainSlideMenuViewModelImple(memberUsecase: self.memberUsecase,
                                                    router: router,
                                                    listener: listener)
        let viewController = MainSlideMenuViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}


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
                                                          remindUsecase: self.remindUsecase,
                                                          router: router)
        let viewController = ReadCollectionItemsViewController(viewModel: viewModel)
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

extension DependencyInjector: NavigateCollectionSceneBuilable {
    
    public func makeNavigateCollectionScene(collection: ReadCollection?,
                                            listener: NavigateCollectionSceneListenable?) -> NavigateCollectionScene {
        
        let router = NavigateCollectionRouter(nextSceneBuilders: self)
        let viewModel = NavigateCollectionViewModelImple(currentCollection: collection,
                                                         readItemUsecase: self.readItemUsecase,
                                                         router: router,
                                                         listener: listener)
        let viewController = NavigateCollectionViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}



// MARK: - EditReadItemScene

extension DependencyInjector: AddItemNavigationSceneBuilable {
    
    public func makeAddItemNavigationScene(at collectionID: String?,
                                           startWith: String?,
                                           _ listener: AddItemNavigationSceneListenable?) -> AddItemNavigationScene {
        let router = AddItemNavigationRouter(nextSceneBuilders: self)
        let viewModel = AddItemNavigationViewModelImple(startWith: startWith,
                                                        targetCollectionID: collectionID,
                                                        router: router,
                                                        listener: listener)
        let viewController = AddItemNavigationViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}


extension DependencyInjector: EnterLinkURLSceneBuilable {
    
    public func makeEnterLinkURLScene(startWith: String?,
                                      _ entered: @escaping (String) -> Void) -> EnterLinkURLScene {
        let router = EnterLinkURLRouter(nextSceneBuilders: self)
        let viewModel = EnterLinkURLViewModelImple(startWith: startWith,
                                                   router: router, callback: entered)
        let viewController = EnterLinkURLViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}


extension DependencyInjector: EditLinkItemSceneBuilable {
    
    public func makeEditLinkItemScene(_ editCase: EditLinkItemCase,
                                      collectionID: String?,
                                      listener: EditLinkItemSceneListenable?) -> EditLinkItemScene {
        
        let router = EditLinkItemRouter(nextSceneBuilders: self)
        let viewModel = EditLinkItemViewModelImple(collectionID: collectionID,
                                                   editCase: editCase,
                                                   readUsecase: self.readItemUsecase,
                                                   categoryUsecase: self.categoryUsecase,
                                                   router: router,
                                                   listener: listener)
        let viewController = EditLinkItemViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension DependencyInjector: EditReadCollectionSceneBuilable {
    
    public func makeEditReadCollectionScene(parentID: String?,
                                            editCase: EditCollectionCase,
                                            listener: EditReadCollectionSceneListenable?) -> EditReadCollectionScene {
        
        let router = EditReadCollectionRouter(nextSceneBuilders: self)
        let viewModel = EditReadCollectionViewModelImple(parentID: parentID,
                                                         editCase: editCase,
                                                         updateUsecase: self.readItemUsecase,
                                                         categoriesUsecase: self.categoryUsecase,
                                                         remindUsecase: self.remindUsecase,
                                                         router: router,
                                                         listener: listener)
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


extension DependencyInjector: EditItemsCustomOrderSceneBuilable {
    
    public func makeEditItemsCustomOrderScene(collectionID: String?,
                                              listener: EditItemsCustomOrderSceneListenable?) -> EditItemsCustomOrderScene {
        let router = EditItemsCustomOrderRouter(nextSceneBuilders: self)
        let viewModel = EditItemsCustomOrderViewModelImple(collectionID: collectionID,
                                                           readItemUsecase: self.readItemUsecase,
                                                           router: router,
                                                           listener: listener)
        let viewController = EditItemsCustomOrderViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}


extension DependencyInjector: EditReadRemindSceneBuilable {
    
    public func makeEditReadRemindScene(_ editCase: EditRemindCase,
                                        listener: EditReadRemindSceneListenable?) -> EditReadRemindScene {
        let router = EditReadRemindRouter(nextSceneBuilders: self)
        let viewModel = EditReadRemindViewModelImple(editCase,
                                                     remindUsecase: self.remindUsecase,
                                                     router: router, listener: listener)
        let viewController = EditReadRemindViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}


// MARK: - ViewerScenes

extension DependencyInjector: InnerWebViewSceneBuilable {
    
    public func makeInnerWebViewScene(link: ReadLink) -> InnerWebViewScene {
        let router = InnerWebViewRouter(nextSceneBuilders: self)
        let viewModel = InnerWebViewViewModelImple(link: link,
                                                   readItemUsecase: self.readItemUsecase,
                                                   memoUsecase: self.memoUsecase,
                                                   router: router)
        let viewController = InnerWebViewViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension DependencyInjector: LinkMemoSceneBuilable {
    
    public func makeLinkMemoScene(memo: ReadLinkMemo, listener: LinkMemoSceneListenable?) -> LinkMemoScene {
        let router = LinkMemoRouter(nextSceneBuilders: self)
        let viewModel = LinkMemoViewModelImple(memo: memo,
                                               memoUsecase: self.memoUsecase,
                                               router: router, listener: listener)
        let viewController = LinkMemoViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}


// MARK: - SettingScenes

extension DependencyInjector: SettingMainSceneBuilable {
    
    public func makeSettingMainScene(listener: SettingMainSceneListenable?) -> SettingMainScene {
        let router = SettingMainRouter(nextSceneBuilders: self)
        let viewModel = SettingMainViewModelImple(memberUsecase: self.memberUsecase,
                                                  remindOptionUsecase: self.remindOptionUsecase,
                                                  router: router, listener: listener)
        let viewController = SettingMainViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

