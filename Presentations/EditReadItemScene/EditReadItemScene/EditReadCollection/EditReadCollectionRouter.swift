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

public protocol EditReadCollectionRouting: Routing, Sendable {
    
    func selectPriority(startWith: ReadPriority?)
    
    func selectCategories(startWith: [ItemCategory])
    
    func updateRemind(_ editCase: EditRemindCase)
    
    func selectParentCollection(statrWith parent: ReadCollection?,
                                withoutSelect unselectableCollection: ReadCollection?)
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
        
        Task { @MainActor in
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
    }
    
    public func selectCategories(startWith: [ItemCategory]) {
        
        Task { @MainActor in
            guard let next = self.nextScenesBuilder?.makeEditCategoryScene(
                startWith: startWith,
                listener: self.currentInteractor)
            else {
                return
            }
            self.currentScene?.present(next, animated: true, completion: nil)
        }
    }
    
    public func updateRemind(_ editCase: EditRemindCase) {
            
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
    
    public func selectParentCollection(statrWith parent: ReadCollection?,
                                       withoutSelect unselectableCollection: ReadCollection?) {
        
        Task { @MainActor in
            guard let parent = parent else {
                self.showNavigationSceneWithoutJump(withoutSelect: unselectableCollection)
                return
            }
            
            self.showNavigationSceneWithJump(parent, withoutSelect: unselectableCollection)
        }
    }
    
    @MainActor
    private func showNavigationSceneWithoutJump(withoutSelect unselectableCollection: ReadCollection?) {
        
        guard let root = self.nextScenesBuilder?
            .makeNavigateCollectionScene(collection: nil,
                                         withoutSelect: unselectableCollection?.uid,
                                         listener: self.currentInteractor)
        else { return }
        
        let sheetController = NavigationEmbedSheetViewController()
        sheetController.embedNavigationController.pushViewController(root, animated: false)
        self.currentBaseViewControllerScene?.presentPageSheetOrFullScreen(sheetController, animated: true)
    }
    
    @MainActor
    private func showNavigationSceneWithJump(_ parent: ReadCollection,
                                             withoutSelect unselectableCollection: ReadCollection?) {
        
        let sheetController = NavigationEmbedSheetViewController()
        self.prepareInverseCoordinator(sheetController.embedNavigationController,
                                       withoutSelect: unselectableCollection)
        
        guard let root = self.nextScenesBuilder?
            .makeNavigateCollectionScene(collection: nil,
                                         withoutSelect: unselectableCollection?.uid,
                                         listener: self.currentInteractor),
              let dest = self.nextScenesBuilder?
            .makeNavigateCollectionScene(collection: parent,
                                         withoutSelect: unselectableCollection?.uid,
                                         listener: self.currentInteractor,
                                         coordinator: self.collectionInverseNavigationCoordinator)
        else { return }
        sheetController.embedNavigationController.viewControllers = [root, dest]
        
        self.currentBaseViewControllerScene?.presentPageSheetOrFullScreen(sheetController, animated: true)
    }
    
    @MainActor
    private func prepareInverseCoordinator(_ navigationController: UINavigationController,
                                           withoutSelect unselectableCollection: ReadCollection?) {
        
        let makeParent: (CollectionInverseParentMakeParameter) -> UIViewController?
        makeParent = { [weak self] parameter in
            let collection = parameter as? ReadCollection
            let parent = self?.nextScenesBuilder?.makeNavigateCollectionScene(
                collection: collection,
                withoutSelect: unselectableCollection?.uid,
                listener: self?.currentInteractor
            )
            return parent
        }
        
        self.collectionInverseNavigationCoordinator = .init(navigationController: navigationController,
                                                            makeParent: makeParent)
    }
}
