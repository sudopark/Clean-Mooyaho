//
//  
//  EnterHoorayImageRouter.swift
//  HoorayScene
//
//  Created by sudo.park on 2021/06/06.
//
//  HoorayScene
//
//  Created sudo.park on 2021/06/06.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Routing

public protocol EnterHoorayImageRouting: Routing {
    
    func askImagePickingModel(_ form: ActionSheetForm)
    
    func presentEditScene(selectImage image: UIImage, edited: (UIImage) -> Void)
    
    func presentImagePicker(isCamera: Bool) -> ImagePickerScenePresenter?
    
    func presentNextInputStage(_ form: NewHoorayForm, selectedImage: String?)
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias EnterHoorayImageRouterBuildables = ImagePickerSceneBuilable & MakeHooraySceneBuilable

public final class EnterHoorayImageRouter: Router<EnterHoorayImageRouterBuildables>, EnterHoorayImageRouting {
    
    weak var bottomSlideDismissAnimator: BottomSlideTransitionAnimationManager?
    
    public init(transitionManager: BottomSlideTransitionAnimationManager?,
                builders: EnterHoorayImageRouterBuildables) {
        self.bottomSlideDismissAnimator = transitionManager
        super.init(nextSceneBuilders: builders)
    }
}


extension EnterHoorayImageRouter {
    
    public func askImagePickingModel(_ form: ActionSheetForm) {
        self.alertActionSheet(form)
    }
    
    public func presentEditScene(selectImage image: UIImage, edited: (UIImage) -> Void) {
        logger.todoImplement()
    }
    
    public func presentImagePicker(isCamera: Bool) -> ImagePickerScenePresenter? {
        
        guard let next = self.nextScenesBuilder?.makeImagePickerScene(isCamera: isCamera) else { return nil }
        
        return next.presenter
    }
    
    public func presentNextInputStage(_ form: NewHoorayForm, selectedImage: String?) {
        
        guard let presenting = self.currentScene?.presentingViewController,
              let transtionManager = self.bottomSlideDismissAnimator,
              let next = self.nextScenesBuilder?
                .makeEnterHoorayMessageScene(form: form,
                                             previousSelectImagePath: selectedImage,
                                             transitionManager: self.bottomSlideDismissAnimator) else {
            return
        }
        next.modalPresentationStyle = .custom
        next.transitioningDelegate = transtionManager
        next.setupDismissGesture(transtionManager.dismissalInteractor)
        self.currentScene?.dismiss(animated: true) { [weak presenting] in
            presenting?.present(next, animated: true, completion: nil)
        }
    }
}
