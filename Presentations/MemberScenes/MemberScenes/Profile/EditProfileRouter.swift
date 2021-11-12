//
//  
//  EditProfileRouter.swift
//  MemberScenes
//
//  Created by sudo.park on 2021/05/30.
//
//  MemberScenes
//
//  Created sudo.park on 2021/05/30.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol EditProfileRouting: Routing {
    
    func editText(mode: TextInputMode, listener: TextInputSceneListenable)
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias EditProfileRouterBuildables = TextInputSceneBuilable

public final class EditProfileRouter: Router<EditProfileRouterBuildables>, EditProfileRouting {
    
    private let bottomSliderTransitionManager = BottomSlideTransitionAnimationManager()
}


extension EditProfileRouter {
    
    private var currentInteractor: EditProfileSceneInteractable? {
        return (self.currentScene as? EditProfileScene)?.interactor
    }
    
    // EditProfileRouting implements
    public func editText(mode: TextInputMode, listener: TextInputSceneListenable) {
        guard let next = self.nextScenesBuilder?.makeTextInputScene(mode, listener: listener)
        else {
            return
        }
        next.modalPresentationStyle = .custom
        next.transitioningDelegate = self.bottomSliderTransitionManager
        next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
        self.currentScene?.present(next, animated: true, completion: nil)
    }
}
