//
//  
//  SearchNewPlaceRouter.swift
//  PlaceScenes
//
//  Created by sudo.park on 2021/06/11.
//
//  PlaceScenes
//
//  Created sudo.park on 2021/06/11.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Routing

public protocol SearchNewPlaceRouting: Routing {
    
    func showPlaceDetail(_ placeID: String, link: String)
    
    func showSelectPlaceCateTag() -> SelectTagScenePresenter?
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias SearchNewPlaceRouterBuildables = SelectTagSceneBuilable

public final class SearchNewPlaceRouter: Router<SearchNewPlaceRouterBuildables>, SearchNewPlaceRouting {
    
    private let bottomSliderTransitionManager = BottomSlideTransitionAnimationManager()
}


extension SearchNewPlaceRouter {
    
    // SearchNewPlaceRouting implements
    public func showPlaceDetail(_ placeID: String, link: String) {
        logger.todoImplement()
    }
    
    public func showSelectPlaceCateTag() -> SelectTagScenePresenter? {
        guard let next = self.nextScenesBuilder?.makeSelectTagScene() else { return nil }
        next.modalPresentationStyle = .custom
        next.transitioningDelegate = self.bottomSliderTransitionManager
        next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
        self.currentScene?.present(next, animated: true, completion: nil)
        return next.presenter
    }
}
