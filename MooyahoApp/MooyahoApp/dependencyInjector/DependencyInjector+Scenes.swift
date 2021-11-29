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
import DiscoveryScene
import SuggestScene


// MARK: - Main Sceens

extension DependencyInjector: MainSceneBuilable {
    
    public func makeMainScene(auth: Auth) -> MainScene {
        
        let itemUsecase = self.readItemUsecaseImple
        let router = MainRouter(nextSceneBuilders: self)
        let viewModel = MainViewModelImple(memberUsecase: self.memberUsecase,
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



// MARK: - ReadItemScene

extension DependencyInjector: ReadCollectionMainSceneBuilable {
    
    public func makeReadCollectionMainScene(navigationListener: ReadCollectionNavigateListenable?) -> ReadCollectionMainScene {
        let router = ReadCollectionMainRouter(nextSceneBuilders: self)
        let viewModel = ReadCollectionMainViewModelImple(router: router, navigationListener: navigationListener)
        let viewController = ReadCollectionMainViewController(viewModel: viewModel)
        router.currentScene = viewController
        router.navigationListener = navigationListener
        return viewController
    }
}

extension DependencyInjector: ReadCollectionItemSceneBuilable {
    
    public func makeReadCollectionItemScene(collectionID: String?,
                                            navigationListener: ReadCollectionNavigateListenable?,
                                            withInverse coordinator: CollectionInverseNavigationCoordinating?) -> ReadCollectionScene {
        let router = ReadCollectionItemsRouter(nextSceneBuilders: self)
        let usecase = self.readItemUsecase
        let viewModel = ReadCollectionViewItemsModelImple(collectionID: collectionID,
                                                          readItemUsecase: usecase,
                                                          favoriteUsecase: usecase,
                                                          categoryUsecase: self.categoryUsecase,
                                                          remindUsecase: self.remindUsecase,
                                                          router: router,
                                                          navigationListener: navigationListener,
                                                          inverseNavigationCoordinating: coordinator)
        let viewController = ReadCollectionItemsViewController(viewModel: viewModel)
        router.currentScene = viewController
        router.navigationListener = navigationListener
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
    
    public func makeInnerWebViewScene(link: ReadLink,
                                      isEditable: Bool,
                                      listener: InnerWebViewSceneListenable?) -> InnerWebViewScene {
        let router = InnerWebViewRouter(nextSceneBuilders: self)
        let viewModel = InnerWebViewViewModelImple(itemSource: .item(link),
                                                   isEditable: isEditable,
                                                   readItemUsecase: self.readItemUsecase,
                                                   memoUsecase: self.memoUsecase,
                                                   router: router,
                                                   listener: listener)
        let viewController = InnerWebViewViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
    
    func makeInnerWebViewScene(linkID: String,
                               isEditable: Bool,
                               isJumpable: Bool,
                               listener: InnerWebViewSceneListenable?) -> InnerWebViewScene {
        let router = InnerWebViewRouter(nextSceneBuilders: self)
        let viewModel = InnerWebViewViewModelImple(itemSource: .itemID(linkID),
                                                   isEditable: isEditable,
                                                   isJumpable: isJumpable,
                                                   readItemUsecase: self.readItemUsecase,
                                                   memoUsecase: self.memoUsecase,
                                                   router: router,
                                                   listener: listener)
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


extension DependencyInjector: WaitMigrationSceneBuilable {
    
    public func makeWaitMigrationScene(userID: String,
                                       shouldResume: Bool,
                                       listener: WaitMigrationSceneListenable?) -> WaitMigrationScene {
        let router = WaitMigrationRouter(nextSceneBuilders: self)
        let viewModel = WaitMigrationViewModelImple(userID: userID,
                                                    shouldResume: shouldResume,
                                                    migrationUsecase: self.userDataMigrationUsecase,
                                                    router: router,
                                                    listener: listener)
        let viewController = WaitMigrationViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}


// MARK: - DiscoveryScenes

extension DependencyInjector: DiscoveryMainSceneBuilable {
    
    public func makeDiscoveryMainScene(currentShareCollectionID: String?,
                                       listener: DiscoveryMainSceneListenable?,
                                       collectionMainInteractor: ReadCollectionMainSceneInteractable?) -> DiscoveryMainScene {
        let router = DiscoveryMainRouter(nextSceneBuilders: self)
        let viewModel = DiscoveryMainViewModelImple(currentSharedCollectionShareID: currentShareCollectionID,
                                                    sharedReadCollectionLoadUsecase: self.shareItemUsecase,
                                                    memberUsecase: self.memberUsecase,
                                                    router: router, listener: listener)
        let viewController = DiscoveryMainViewController(viewModel: viewModel)
        router.currentScene = viewController
        router.collectionMainInteractor = collectionMainInteractor
        return viewController
    }
}

extension DependencyInjector: StopShareCollectionSceneBuilable {
    
    public func makeStopShareCollectionScene(_ collectionID: String,
                                             listener: StopShareCollectionSceneListenable?) -> StopShareCollectionScene {
        let router = StopShareCollectionRouter(nextSceneBuilders: self)
        let viewModel = StopShareCollectionViewModelImple(shareURLScheme: AppEnvironment.shareScheme,
                                                          collectionID: collectionID,
                                                          shareCollectionUsecase: self.shareItemUsecase,
                                                          router: router, listener: nil)
        let viewController = StopShareCollectionViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension DependencyInjector: SharedCollectionItemsSceneBuilable {
    
    public func makeSharedCollectionItemsScene(currentCollection: SharedReadCollection,
                                               listener: SharedCollectionItemsSceneListenable?,
                                               navigationListener: ReadCollectionNavigateListenable?) -> SharedCollectionItemsScene {
        
        let itemsUsecase = self.readItemUsecase
        let router = SharedCollectionItemsRouter(nextSceneBuilders: self)
        router.navigationListener = navigationListener
        let viewModel = SharedCollectionItemsViewModelImple(currentCollection: currentCollection,
                                                            loadSharedCollectionUsecase: self.shareItemUsecase,
                                                            linkPreviewLoadUsecase: itemsUsecase,
                                                            readItemOptionsUsecase: itemsUsecase,
                                                            categoryUsecase: self.categoryUsecase,
                                                            router: router,
                                                            listener: nil,
                                                            navigationListener: navigationListener)
        let viewController = SharedCollectionItemsViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension DependencyInjector: SharedCollectionInfoDialogSceneBuilable {
    
    public func makeSharedCollectionInfoDialogScene(collection: SharedReadCollection,
                                                    listener: SharedCollectionInfoDialogSceneListenable?) -> SharedCollectionInfoDialogScene {
        let router = SharedCollectionInfoDialogRouter(nextSceneBuilders: self)
        let viewModel = SharedCollectionInfoDialogViewModelImple(collection: collection,
                                                                 shareItemsUsecase: self.shareItemUsecase,
                                                                 router: router,
                                                                 listener: listener)
        let viewController = SharedCollectionInfoDialogViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}


// MARK: - suggest

extension DependencyInjector: IntegratedSearchSceneBuilable {
    
    private var suggestQueryUSecase: SuggestQueryUsecase & SuggestableQuerySyncUsecase {
        return SuggestQueryUsecaseImple(suggestQueryEngine: self.suggestQueryEngine,
                                        searchRepository: self.appReposiotry)
    }
    
    public func makeIntegratedSearchScene(listener: IntegratedSearchSceneListenable?,
                                          readCollectionMainInteractor: ReadCollectionMainSceneInteractable?) -> IntegratedSearchScene {
        let router = IntegratedSearchRouter(nextSceneBuilders: self)
        
        let suggestUsecase = self.suggestQueryUSecase
        router.suggestQueryUsecase = suggestUsecase
        
        let searchUsecase = IntegratedSearchUsecaseImple(suggestQuerySyncUsecase: suggestUsecase,
                                                         searchRepository: self.appReposiotry)
        let viewModel = IntegratedSearchViewModelImple(searchUsecase: searchUsecase,
                                                       categoryUsecase: self.categoryUsecase,
                                                       router: router,
                                                       listener: listener,
                                                       readCollectionMainInteractor: readCollectionMainInteractor)
        let viewController = IntegratedSearchViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}


extension DependencyInjector: SuggestQuerySceneBuilable {
    
    public func makeSuggestQueryScene(suggestQueryUsecase: SuggestQueryUsecase,
                                      listener: SuggestQuerySceneListenable?) -> SuggestQueryScene {
        let router = SuggestQueryRouter(nextSceneBuilders: self)
        let viewModel = SuggestQueryViewModelImple(suggestQueryUsecase: suggestQueryUsecase,
                                                   router: router,
                                                   listener: listener)
        let viewController = SuggestQueryViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}


extension DependencyInjector: SuggestReadSceneBuilable {
    
    public func makeSuggestReadScene(
        listener: SuggestReadSceneListenable?,
        readCollectionMainInteractor: ReadCollectionMainSceneInteractable?
    ) -> SuggestReadScene {
        let router = SuggestReadRouter(nextSceneBuilders: self)
        
        let viewModel = SuggestReadViewModelImple (
            readItemUsecase: self.readItemUsecase,
            categoriesUsecase: self.categoryUsecase,
            router: router,
            listener: listener,
            readCollectionMainInteractor: readCollectionMainInteractor
        )
        let viewController = SuggestReadViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}
