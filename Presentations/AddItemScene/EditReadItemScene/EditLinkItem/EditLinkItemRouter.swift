//
//  
//  EditLinkItemRouter.swift
//  EditReadItemScene
//
//  Created by sudo.park on 2021/10/03.
//
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/03.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Routing

public protocol EditLinkItemRouting: Routing {
    
    func requestRewind()
    
    func editPriority(startWith priority: ReadPriority?)
    
    func editCategory(startWith categories: [ItemCategory])
    
    func editRemind(_ editCase: EditRemindCase)
    
    func editParentCollection(_ current: ReadCollection?)
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias EditLinkItemRouterBuildables = EditReadPrioritySceneBuilable & EditCategorySceneBuilable & EditReadRemindSceneBuilable & NavigateCollectionSceneBuilable

public final class EditLinkItemRouter: Router<EditLinkItemRouterBuildables>, EditLinkItemRouting {
    
    private let bottomSliderTransitionManager = BottomSlideTransitionAnimationManager()
    private var collectionInverseNavigationCoordinator: CollectionInverseNavigationCoordinator?
}


extension EditLinkItemRouter {
    
    private var currentInteractor: EditLinkItemSceneInteractable? {
        return (self.currentScene as? EditLinkItemScene)?.interactor
    }
    
    // EditLinkItemRouting implements
    public func requestRewind() {
        
        guard let navigation = self.currentScene?.navigationController?.parent as? AddItemNavigationScene else {
            return
        }
        navigation.interactor?.requestpopToEnrerURLScene()
    }
    
    public func editPriority(startWith priority: ReadPriority?) {
        
        guard let next = self.nextScenesBuilder?
                .makeSelectPriorityScene(startWithSelected: priority, listener: self.currentInteractor) else {
            return
        }
        
        next.modalPresentationStyle = .custom
        next.transitioningDelegate = self.bottomSliderTransitionManager
        next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
        self.currentScene?.present(next, animated: true, completion: nil)
    }
    
    public func editCategory(startWith categories: [ItemCategory]) {
        
        guard let next = self.nextScenesBuilder?
                .makeEditCategoryScene(startWith: categories, listener: self.currentInteractor) else {
            return
        }
        self.currentScene?.present(next, animated: true, completion: nil)
    }
    
    public func editRemind(_ editCase: EditRemindCase) {
        
        guard let next = self.nextScenesBuilder?
                .makeEditReadRemindScene(editCase, listener: self.currentInteractor)
        else { return }
        
        next.modalPresentationStyle = .custom
        next.transitioningDelegate = self.bottomSliderTransitionManager
        next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
        self.currentScene?.present(next, animated: true, completion: nil)
    }
    
    public func editParentCollection(_ current: ReadCollection?) {
        
        guard let current = current else {
            self.showNavigationSceneWithoutJump()
            return
        }

        self.showNavigationSceneWithJump(current)
    }
    
    private func showNavigationSceneWithoutJump() {
        
        guard let root = self.nextScenesBuilder?
            .makeNavigateCollectionScene(collection: nil, listener: self.currentInteractor)
        else { return }
        
        let navigationController = self.makeNavaigationController(root)
        self.currentBaseViewControllerScene?.presentPageSheetOrFullScreen(navigationController, animated: true)
    }
    
    private func showNavigationSceneWithJump(_ current: ReadCollection) {
        
        let navigationController = self.makeNavaigationController()
        self.prepareInverseCoordinator(navigationController)
        
        guard let root = self.nextScenesBuilder?
            .makeNavigateCollectionScene(collection: nil, listener: self.currentInteractor),
              let dest = self.nextScenesBuilder?
            .makeNavigateCollectionScene(collection: current, listener: self.currentInteractor, coordinator: self.collectionInverseNavigationCoordinator)
        else { return }
        navigationController.viewControllers = [root, dest]
        
        self.currentBaseViewControllerScene?.presentPageSheetOrFullScreen(navigationController, animated: true)
    }
    
    private func makeNavaigationController(_ root: UIViewController? = nil) -> BaseNavigationController {
        return BaseNavigationController(
            rootViewController: root,
            shouldHideNavigation: false,
            shouldShowCloseButtonIfNeed: true
        )
    }
    
    private func prepareInverseCoordinator(_ navigationController: UINavigationController) {
        
        let makeParent: (CollectionInverseParentMakeParameter) -> UIViewController?
        makeParent = { [weak self] parameter in
            let collection = parameter as? ReadCollection
            let parent = self?.nextScenesBuilder?.makeNavigateCollectionScene(
                collection: collection,
                listener: self?.currentInteractor
            )
            return parent
        }
        
        self.collectionInverseNavigationCoordinator = .init(navigationController: navigationController,
                                                            makeParent: makeParent)
    }
}
