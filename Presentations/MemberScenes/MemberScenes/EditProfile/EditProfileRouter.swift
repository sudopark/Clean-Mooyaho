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

public protocol EditProfileRouting: Routing, Sendable {
    
    func editText(mode: TextInputMode, listener: TextInputSceneListenable)
    
    func chooseProfileImageSource(_ form: ActionSheetForm)
    
    func selectEmoji()
    
    func selectPhoto()
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias EditProfileRouterBuildables = TextInputSceneBuilable & ImagePickerSceneBuilable & SelectEmojiSceneBuilable

public final class EditProfileRouter: Router<EditProfileRouterBuildables>, EditProfileRouting {
    
    @MainActor private let bottomSliderTransitionManager = BottomSlideTransitionAnimationManager()
}


extension EditProfileRouter {
    
    private var currentInteractor: EditProfileSceneInteractable? {
        return (self.currentScene as? EditProfileScene)?.interactor
    }

    // EditProfileRouting implements
    public func editText(mode: TextInputMode, listener: TextInputSceneListenable) {
        
        Task { @MainActor in
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
    
    public func chooseProfileImageSource(_ form: ActionSheetForm) {
        self.alertActionSheet(form)
    }
    
    public func selectEmoji() {
        Task { @MainActor in
            guard let next = self.nextScenesBuilder?.makeSelectEmojiScene(listener: self.currentInteractor)
            else {
                return
            }
            self.currentScene?.present(next, animated: true, completion: nil)
        }
    }
    
    public func selectPhoto() {
        Task { @MainActor in
            guard let next = self.nextScenesBuilder?
                    .makeImagePickerScene(isCamera: false, listener: self.currentInteractor)
            else {
                return
            }
            self.currentScene?.present(next, animated: true, completion: nil)
        }
    }
}
