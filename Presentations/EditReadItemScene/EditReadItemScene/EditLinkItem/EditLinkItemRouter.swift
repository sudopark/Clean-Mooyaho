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

public protocol EditLinkItemRouting: Routing, Sendable {
    
    func requestRewind()
    
    func editPriority(startWith priority: ReadPriority?)
    
    func editCategory(startWith categories: [ItemCategory])
    
    func editRemind(_ editCase: EditRemindCase)
    
    func editParentCollection(_ parent: ReadCollection?)
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
        
        Task { @MainActor in
            guard let navigation = self.currentScene?.navigationController?.parent as? AddItemNavigationScene else {
                return
            }
            navigation.interactor?.requestpopToEnrerURLScene()
        }
    }
    
    public func editPriority(startWith priority: ReadPriority?) {
        
        Task { @MainActor in
            guard let next = self.nextScenesBuilder?
                    .makeSelectPriorityScene(startWithSelected: priority, listener: self.currentInteractor) else {
                return
            }
            
            next.modalPresentationStyle = .custom
            next.transitioningDelegate = self.bottomSliderTransitionManager
            next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
            self.currentScene?.present(next, animated: true, completion: nil)
        }
    }
    
    public func editCategory(startWith categories: [ItemCategory]) {
        
        Task { @MainActor in
            guard let next = self.nextScenesBuilder?
                    .makeEditCategoryScene(startWith: categories, listener: self.currentInteractor) else {
                return
            }
            self.currentScene?.present(next, animated: true, completion: nil)
        }
    }
    
    public func editRemind(_ editCase: EditRemindCase) {
        
        Task { @MainActor in
            guard let next = self.nextScenesBuilder?
                    .makeEditReadRemindScene(editCase, listener: self.currentInteractor)
            else { return }
            
            next.modalPresentationStyle = .custom
            next.transitioningDelegate = self.bottomSliderTransitionManager
            next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
            self.currentScene?.present(next, animated: true, completion: nil)
        }
    }
    
    public func editParentCollection(_ parent: ReadCollection?) {
        
        Task { @MainActor in
            guard let parent = parent else {
                self.showNavigationSceneWithoutJump()
                return
            }

            self.showNavigationSceneWithJump(parent)
        }
    }
    
    @MainActor
    private func showNavigationSceneWithoutJump() {
        
        guard let root = self.nextScenesBuilder?
            .makeNavigateCollectionScene(collection: nil,
                                         withoutSelect: nil,
                                         listener: self.currentInteractor)
        else { return }
        
        let sheetController = NavigationEmbedSheetViewController()
        sheetController.embedNavigationController.pushViewController(root, animated: false)
        self.currentBaseViewControllerScene?.presentPageSheetOrFullScreen(sheetController, animated: true)
    }
    
    @MainActor
    private func showNavigationSceneWithJump(_ current: ReadCollection) {
        
        let sheetController = NavigationEmbedSheetViewController()
        self.prepareInverseCoordinator(sheetController.embedNavigationController)
        
        guard let root = self.nextScenesBuilder?
            .makeNavigateCollectionScene(collection: nil,
                                         withoutSelect: nil,
                                         listener: self.currentInteractor),
              let dest = self.nextScenesBuilder?
            .makeNavigateCollectionScene(collection: current,
                                         withoutSelect: nil,
                                         listener: self.currentInteractor,
                                         coordinator: self.collectionInverseNavigationCoordinator)
        else { return }
        sheetController.embedNavigationController.viewControllers = [root, dest]
        
        self.currentBaseViewControllerScene?.presentPageSheetOrFullScreen(sheetController, animated: true)
    }
    
    @MainActor
    private func prepareInverseCoordinator(_ navigationController: UINavigationController) {
        
        let makeParent: (CollectionInverseParentMakeParameter) -> UIViewController?
        makeParent = { [weak self] parameter in
            let collection = parameter as? ReadCollection
            let parent = self?.nextScenesBuilder?.makeNavigateCollectionScene(
                collection: collection,
                withoutSelect: nil,
                listener: self?.currentInteractor
            )
            return parent
        }
        
        self.collectionInverseNavigationCoordinator = .init(navigationController: navigationController,
                                                            makeParent: makeParent)
    }
}
