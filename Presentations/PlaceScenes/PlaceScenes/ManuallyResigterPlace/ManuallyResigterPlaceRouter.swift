//
//  
//  ManuallyResigterPlaceRouter.swift
//  PlaceScenes
//
//  Created by sudo.park on 2021/06/12.
//
//  PlaceScenes
//
//  Created sudo.park on 2021/06/12.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Routing

public protocol ManuallyResigterPlaceRouting: Routing {
    
    func addSmallMapView() -> LocationMarkSceneInput?
    
    func openPlaceTitleInputScene(_ mode: TextInputMode) -> TextInputSceneOutput?
    
    func openLocationSelectScene(_ previousInfo: Location?) -> LocationSelectSceneOutput?
    
    func openTagSelectScene(_ tags: [Tag], total: [Tag]) -> SelectTagSceneOutput?
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias ManuallyResigterPlaceRouterBuildables = LocationSelectSceneBuilable & TextInputSceneBuilable
    & LocationMarkSceneBuilable & SelectTagSceneBuilable

public final class ManuallyResigterPlaceRouter: Router<ManuallyResigterPlaceRouterBuildables>, ManuallyResigterPlaceRouting {
    
    private let bottomSliderTransitionManager = BottomSlideTransitionAnimationManager()
}


extension ManuallyResigterPlaceRouter {
    
    public func addSmallMapView() -> LocationMarkSceneInput? {
        guard let manualScene = self.currentScene as? ManuallyResigterPlaceScene,
              let next = self.nextScenesBuilder?.makeLocationMarkScene() else { return nil }
        next.view.frame = CGRect(origin: .zero, size: manualScene.childContainerView.frame.size)
        next.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        manualScene.addChild(next)
        manualScene.childContainerView.addSubview(next.view)
        next.didMove(toParent: manualScene)
        
        return next.input
    }
    
    public func openPlaceTitleInputScene(_ mode: TextInputMode) -> TextInputSceneOutput? {
        
        guard let next = self.nextScenesBuilder?.makeTextInputScene(mode) else { return nil }
        next.modalPresentationStyle = .custom
        next.transitioningDelegate = self.bottomSliderTransitionManager
        next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
        self.currentScene?.present(next, animated: true, completion: nil)
        
        return next.output
    }
    
    public func openLocationSelectScene(_ previousInfo: Location?) -> LocationSelectSceneOutput? {
        guard let next = self.nextScenesBuilder?.makeLocationSelectScene(previousInfo) else { return nil }
        self.currentScene?.present(next, animated: true, completion: nil)
        return next.output
    }
    
    public func openTagSelectScene(_ tags: [Tag], total: [Tag]) -> SelectTagSceneOutput? {
        guard let next = self.nextScenesBuilder?
                .makeSelectTagScene(startWith: tags, total: total) else { return nil }
        next.modalPresentationStyle = .custom
        next.transitioningDelegate = self.bottomSliderTransitionManager
        next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
        self.currentScene?.present(next, animated: true, completion: nil)
        return next.presenter
    }
}
