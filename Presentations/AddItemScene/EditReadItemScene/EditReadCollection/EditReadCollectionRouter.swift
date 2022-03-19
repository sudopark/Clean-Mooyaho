//
//  
//  EditReadCollectionRouter.swift
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

public protocol EditReadCollectionRouting: Routing {
    
    func selectPriority(startWith: ReadPriority?)
    
    func selectCategories(startWith: [ItemCategory])
    
    func updateRemind(_ editCase: EditRemindCase)
    
    func selectParentCollection(statrWith current: ReadCollection?)
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias EditReadCollectionRouterBuildables = EditReadPrioritySceneBuilable & EditCategorySceneBuilable & EditReadRemindSceneBuilable & NavigateCollectionSceneBuilable

public final class EditReadCollectionRouter: Router<EditReadCollectionRouterBuildables>, EditReadCollectionRouting {
    
    private let bottomSliderTransitionManager = BottomSlideTransitionAnimationManager()
    private var collectionInverseNavigationCoordinator: CollectionInverseNavigationCoordinator?
}


extension EditReadCollectionRouter {
    
    // EditReadCollectionRouting implements
    private var currentInteractor: EditReadCollectionSceneInteractable? {
        return (self.currentScene as? EditReadCollectionScene)?.interactor
    }
    
    public func selectPriority(startWith: ReadPriority?) {
        
        guard let next = self.nextScenesBuilder?
                .makeSelectPriorityScene(startWithSelected: startWith,
                                         listener: self.currentInteractor) else {
            return
        }
        next.modalPresentationStyle = .custom
        next.transitioningDelegate = self.bottomSliderTransitionManager
        next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
        self.currentScene?.present(next, animated: true, completion: nil)
    }
    
    public func selectCategories(startWith: [ItemCategory]) {
        
        guard let next = self.nextScenesBuilder?.makeEditCategoryScene(
            startWith: startWith,
            listener: self.currentInteractor)
        else {
            return
        }
        self.currentScene?.present(next, animated: true, completion: nil)
    }
    
    public func updateRemind(_ editCase: EditRemindCase) {
            
        guard let next = self.nextScenesBuilder?
                .makeEditReadRemindScene(editCase, listener: self.currentInteractor)
        else { return }
        next.modalPresentationStyle = .custom
        next.transitioningDelegate = self.bottomSliderTransitionManager
        next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
        self.currentScene?.present(next, animated: true, completion: nil)
    }
    
    public func selectParentCollection(statrWith current: ReadCollection?) {
        
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
        
        let sheetController = NavigationEmbedSheetViewController()
        sheetController.embedNavigationController.pushViewController(root, animated: false)
        self.currentBaseViewControllerScene?.presentPageSheetOrFullScreen(sheetController, animated: true)
    }
    
    private func showNavigationSceneWithJump(_ current: ReadCollection) {
        
        let sheetController = NavigationEmbedSheetViewController()
        self.prepareInverseCoordinator(sheetController.embedNavigationController)
        
        guard let root = self.nextScenesBuilder?
            .makeNavigateCollectionScene(collection: nil, listener: self.currentInteractor),
              let dest = self.nextScenesBuilder?
            .makeNavigateCollectionScene(collection: current, listener: self.currentInteractor, coordinator: self.collectionInverseNavigationCoordinator)
        else { return }
        sheetController.embedNavigationController.viewControllers = [root, dest]
        
        self.currentBaseViewControllerScene?.presentPageSheetOrFullScreen(sheetController, animated: true)
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
