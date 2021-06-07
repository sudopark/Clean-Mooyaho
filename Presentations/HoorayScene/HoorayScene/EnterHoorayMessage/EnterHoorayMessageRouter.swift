//
//  
//  EnterHoorayMessageRouter.swift
//  HoorayScene
//
//  Created by sudo.park on 2021/06/07.
//
//  HoorayScene
//
//  Created sudo.park on 2021/06/07.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Routing

public protocol EnterHoorayMessageRouting: Routing {
    
    func presentNextInputStage(_ form: NewHoorayForm, selectedImage: String?)
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias EnterHoorayMessageRouterBuildables = MakeHooraySceneBuilable

public final class EnterHoorayMessageRouter: Router<EnterHoorayMessageRouterBuildables>, EnterHoorayMessageRouting {
    
    weak var bottomSlideDismissAnimator: BottomSlideTransitionAnimationManager?
    
    public init(transitionManager: BottomSlideTransitionAnimationManager?,
                builders: EnterHoorayMessageRouterBuildables) {
        self.bottomSlideDismissAnimator = transitionManager
        super.init(nextSceneBuilders: builders)
    }
}


extension EnterHoorayMessageRouter {
    
    public func presentNextInputStage(_ form: NewHoorayForm, selectedImage: String?) {
        
        guard let presenting = self.currentScene?.presentingViewController,
              let transtionManager = self.bottomSlideDismissAnimator,
              let next = self.nextScenesBuilder?.makeEnterHoorayTagScene(form: form,
                                                                         previousSelectImagePath: selectedImage) else {
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
