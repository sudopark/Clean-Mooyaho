//
//  
//  MainRouter.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/05/20.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//
//  MooyahoApp
//
//  Created sudo.park on 2021/05/20.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import RxSwift

import Domain
import CommonPresenting
import ReadItemScene


// MARK: - Routing

public protocol MainRouting: Routing {

    func addReadCollectionScene() -> ReadCollectionMainSceneInteractable?
    
    func replaceReadCollectionScene() -> ReadCollectionMainSceneInteractable?
    
    func openSlideMenu()
    
    func presentSignInScene()
    
    func presentUserDataMigrationScene(_ userID: String)
    
    func presentActivateAccountScene(_ userID: String)
    
    func presentEditProfileScene()
    
    func askAddNewitemType(_ completed: @escaping (Bool) -> Void)
    
    func presentShareSheet(with url: String)
    
    func showSharingCollectionInfo(_ collectionID: String)
    
    func showSharedCollection(_ collection: SharedReadCollection)
    
    func showSharedCollectionDialog(for collection: SharedReadCollection)
    
    func addSuggestReadScene() -> SuggestReadSceneInteractable?
    
    func addSaerchScene() -> IntegratedSearchSceneInteractable?
    
    func removeSearchScene()
    
    func showRemindDetail(_ itemID: String)
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias MainRouterBuildables = MainSlideMenuSceneBuilable
    & SignInSceneBuilable & EditProfileSceneBuilable
    & ReadCollectionMainSceneBuilable & SelectAddItemTypeSceneBuilable
    & WaitMigrationSceneBuilable & StopShareCollectionSceneBuilable
    & SharedCollectionInfoDialogSceneBuilable & IntegratedSearchSceneBuilable
    & SuggestReadSceneBuilable & InnerWebViewSceneBuilable
    & RecoverAccountSceneBuilable

public final class MainRouter: Router<MainRouterBuildables>, MainRouting {
    
    private let pushSlideTransitionManager = PushslideTransitionAnimationManager()
    private let bottomSliderTransitionManager = BottomSlideTransitionAnimationManager()
    
    private weak var collectionMainInteractor: ReadCollectionMainSceneInteractable?
}


extension MainRouter {
    
    private var currentInteractor: MainSceneInteractable? {
        return (self.currentScene as? MainScene)?.interactor
    }
    
    public func addReadCollectionScene() -> ReadCollectionMainSceneInteractable? {
        
        guard let mainScene = self.currentScene as? MainScene,
              let collectionMainScene = self.nextScenesBuilder?
                .makeReadCollectionMainScene(navigationListener: self.currentInteractor)
        else {
            return nil
        }
        
        collectionMainScene.view.frame = CGRect(origin: .zero,
                                                size: mainScene.childContainerView.frame.size)
        collectionMainScene.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainScene.addChild(collectionMainScene)
        mainScene.childContainerView.addSubview(collectionMainScene.view)
        collectionMainScene.didMove(toParent: mainScene)
        
        self.collectionMainInteractor = collectionMainScene.interactor
        return collectionMainScene.interactor
    }
    
    public func replaceReadCollectionScene() -> ReadCollectionMainSceneInteractable? {
        
        guard let mainScene = self.currentScene as? MainScene,
              let presentingCollectionMain = mainScene.children
                .compactMap ({ $0 as? ReadCollectionMainScene }).first
        else {
            return nil
        }
        presentingCollectionMain.willMove(toParent: nil)
        presentingCollectionMain.removeFromParent()
        presentingCollectionMain.view.removeFromSuperview()
        
        return self.addReadCollectionScene()
    }
    
    public func openSlideMenu() {
        
        guard let menuScene = self.nextScenesBuilder?
                .makeMainSlideMenuScene(listener: self.currentInteractor,
                                        collectionMainInteractor: self.collectionMainInteractor)
        else {
            return
        }
        
        menuScene.modalPresentationStyle = .custom
        menuScene.transitioningDelegate = self.pushSlideTransitionManager
        menuScene.setupDismissGesture(self.pushSlideTransitionManager.dismissalInteractor)
        self.currentScene?.present(menuScene, animated: true, completion: nil)
    }
    
    public func presentSignInScene() {
        
        guard let scene = self.nextScenesBuilder?.makeSignInScene(nil) else { return }
        
        scene.modalPresentationStyle = .custom
        scene.transitioningDelegate = self.bottomSliderTransitionManager
        self.currentScene?.present(scene, animated: true, completion: nil)
    }
    
    public func presentActivateAccountScene(_ userID: String) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            guard let scene = self.nextScenesBuilder?.makeRecoverAccountScene(listener: self.currentInteractor)
            else {
                return
            }
            scene.modalPresentationStyle = .custom
            scene.transitioningDelegate = self.bottomSliderTransitionManager
            self.currentScene?.present(scene, animated: true, completion: nil)
        }
    }
    
    public func presentUserDataMigrationScene(_ userID: String) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let next = self?.nextScenesBuilder?
                    .makeWaitMigrationScene(userID: userID, shouldResume: false, listener: nil)
            else { return }
            
            next.isModalInPresentation = true
            self?.currentScene?.present(next, animated: true, completion: nil)
        }
    }
    
    public func presentEditProfileScene() {
        
        guard let scene = self.nextScenesBuilder?.makeEditProfileScene() else { return }
        self.currentBaseViewControllerScene?.presentPageSheetOrFullScreen(scene, animated: true)
    }
    
    public func askAddNewitemType(_ completed: @escaping (Bool) -> Void) {
        guard let next = self.nextScenesBuilder?.makeSelectAddItemTypeScene(completed) else { return }
        next.modalPresentationStyle = .custom
        next.transitioningDelegate = self.bottomSliderTransitionManager
        next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
        self.currentScene?.present(next, animated: true, completion: nil)
    }
    
    public func presentShareSheet(with url: String) {
        guard let url = URL(string: url) else { return }
        let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        self.currentScene?.present(activity, animated: true, completion: nil)
    }
    
    public func showSharingCollectionInfo(_ collectionID: String) {
        guard let next = self.nextScenesBuilder?
                .makeStopShareCollectionScene(collectionID, listener: nil)
        else {
            return
        }
        self.currentScene?.present(next, animated: true, completion: nil)
    }
    
    public func showSharedCollection(_ collection: SharedReadCollection) {
        
        self.closeScene(animated: true) { [weak self] in
            self?.collectionMainInteractor?.switchToSharedCollection(collection)
        }
    }
    
    public func showSharedCollectionDialog(for collection: SharedReadCollection) {
        
        guard let next = self.nextScenesBuilder?
                .makeSharedCollectionInfoDialogScene(collection: collection, listener: self.currentInteractor)
        else {
            return
        }
        self.currentScene?.present(next, animated: true, completion: nil)
    }
    
    public func addSuggestReadScene() -> SuggestReadSceneInteractable? {
        
        guard let mainScene = self.currentScene as? MainScene,
              let next = self.nextScenesBuilder?.makeSuggestReadScene(
                listener: self.currentInteractor,
                readCollectionMainInteractor: self.collectionMainInteractor
              )
        else {
            return nil
        }
        
        next.view.frame = CGRect(origin: .zero, size: mainScene.childBottomSlideContainerView.frame.size)
        next.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainScene.addChild(next)
        mainScene.childBottomSlideContainerView.addSubview(next.view)
        next.didMove(toParent: mainScene)
        
        return next.interactor
    }
    
    public func addSaerchScene() -> IntegratedSearchSceneInteractable? {
        
        guard let mainScene = self.currentScene as? MainScene,
              let next = self.nextScenesBuilder?
                .makeIntegratedSearchScene(listener: self.currentInteractor,
                                           readCollectionMainInteractor: self.collectionMainInteractor)
        else {
            return nil
        }
        
        next.view.frame = CGRect(origin: .zero, size: mainScene.childBottomSlideContainerView.frame.size)
        next.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainScene.addChild(next)
        mainScene.childBottomSlideContainerView.addSubview(next.view)
        next.didMove(toParent: mainScene)
        
        return next.interactor
    }
    
    public func removeSearchScene() {
        
        guard let mainScene = self.currentScene as? MainScene,
              let presentingSearchScene = mainScene.children
                .compactMap ({ $0 as? IntegratedSearchScene }).first
        else {
            return
        }
        presentingSearchScene.willMove(toParent: nil)
        presentingSearchScene.removeFromParent()
        presentingSearchScene.view.removeFromSuperview()
    }
    
    public func showRemindDetail(_ itemID: String) {
        guard let next = self.nextScenesBuilder?.makeInnerWebViewScene(
            linkID: itemID,
            isEditable: true,
            isJumpable: true,
            listener: self.currentInteractor
        ) else {
            return
        }
        self.currentScene?.present(next, animated: true, completion: nil)
    }
}
