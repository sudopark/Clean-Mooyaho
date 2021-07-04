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
    
    func showSelectPlaceCateTag(startWith tags: [Tag],
                                total: [Tag]) -> SelectTagSceneOutput?
    
    func showManuallyRegisterPlaceScene(myID: String) -> ManuallyResigterPlaceSceneOutput?
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias SearchNewPlaceRouterBuildables = SelectTagSceneBuilable & ManuallyResigterPlaceSceneBuilable

public final class SearchNewPlaceRouter: Router<SearchNewPlaceRouterBuildables>, SearchNewPlaceRouting {
    
    private let bottomSliderTransitionManager = BottomSlideTransitionAnimationManager()
}


extension SearchNewPlaceRouter {
    
    // SearchNewPlaceRouting implements
    public func showPlaceDetail(_ placeID: String, link: String) {
        logger.todoImplement()
    }
    
    public func showSelectPlaceCateTag(startWith tags: [Tag],
                                       total: [Tag]) -> SelectTagSceneOutput? {
        guard let next = self.nextScenesBuilder?
                .makeSelectTagScene(startWith: tags, total: total) else { return nil }
        next.modalPresentationStyle = .custom
        next.transitioningDelegate = self.bottomSliderTransitionManager
        next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
        self.currentScene?.present(next, animated: true, completion: nil)
        return next.presenter
    }
    
    public func showManuallyRegisterPlaceScene(myID: String) -> ManuallyResigterPlaceSceneOutput? {
        
        guard let next = self.nextScenesBuilder?.makeManuallyResigterPlaceScene(myID: myID) else {
            return nil
        }
        self.currentScene?.present(next, animated: true, completion: nil)
        return next.output
    }
}
