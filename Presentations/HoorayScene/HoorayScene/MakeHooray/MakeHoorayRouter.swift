//
//  
//  MakeHoorayRouter.swift
//  HoorayScene
//
//  Created by sudo.park on 2021/06/04.
//
//  HoorayScene
//
//  Created sudo.park on 2021/06/04.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift

import Domain
import CommonPresenting


// MARK: - Routing

public protocol MakeHoorayRouting: Routing {
    
    func openEditProfileScene() -> EditProfileScenePresenter?
    
    func openEnterHoorayImageScene(_ form: NewHoorayForm) -> Observable<NewHoorayForm>?
    
    func openEnterHoorayMessageScene(_ form: NewHoorayForm,
                                     inputMode: TextInputMode) -> Observable<NewHoorayForm>?
    
    func openEnterHoorayTagScene(_ form: NewHoorayForm) -> EnteringNewHoorayPresenter?
    
    func presentPlaceSelectScene(_ form: NewHoorayForm) -> EnteringNewHoorayPresenter?
    
    func alertShouldWaitPublishNewHooray(_ until: TimeStamp)

}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias MakeHoorayRouterBuildables = MakeHooraySceneBuilable & EditProfileSceneBuilable & WaitNextHooraySceneBuilable & ImagePickerSceneBuilable & TextInputSceneBuilable

public final class MakeHoorayRouter: Router<MakeHoorayRouterBuildables>, MakeHoorayRouting {
    
    private let bottomSliderTransitionManager = BottomSlideTransitionAnimationManager()
}


extension MakeHoorayRouter {
    
    // MakeHoorayRouting implements
    public func openEditProfileScene() -> EditProfileScenePresenter? {
        guard let next = self.nextScenesBuilder?.makeEditProfileScene() else { return nil }
        self.currentScene?.present(next, animated: true, completion: nil)
        return next.presenrer
    }
    
    public func openEnterHoorayTagScene(_ form: NewHoorayForm) -> EnteringNewHoorayPresenter? {
        return routeToEnteringScenes(form, nextMake: self.nextScenesBuilder?.makeEnterHoorayTagScene(form:))
    }
    
    typealias EnteringScene = BaseEnterNewHoorayInfoScene & PangestureDismissableScene
    private func routeToEnteringScenes(_ form: NewHoorayForm,
                                       nextMake: ((NewHoorayForm) -> EnteringScene)?) -> EnteringNewHoorayPresenter? {
        guard let next = nextMake?(form) else { return nil }
        next.modalPresentationStyle = .custom
        next.transitioningDelegate = self.bottomSliderTransitionManager
        next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
        self.currentScene?.present(next, animated: true, completion: nil)
        return next.presenter
    }
    
    public func presentPlaceSelectScene(_ form: NewHoorayForm) -> EnteringNewHoorayPresenter? {
        guard let next = self.nextScenesBuilder?.makeSelectHoorayPlaceScene(form: form) else { return nil }
        self.currentScene?.present(next, animated: true, completion: nil)
        return next.presenter
    }
    
    public func alertShouldWaitPublishNewHooray(_ until: TimeStamp) {
        
        guard let next = self.nextScenesBuilder?.makeWaitNextHoorayScene(until) else { return }
        next.modalPresentationStyle = .custom
        next.transitioningDelegate = self.bottomSliderTransitionManager
        next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
        self.currentScene?.present(next, animated: true, completion: nil)
    }
}


// MARK - use common scene

extension MakeHoorayRouter {
    
    public func openEnterHoorayImageScene(_ form: NewHoorayForm) -> Observable<NewHoorayForm>? {
        
        guard let next = self.nextScenesBuilder?.makeImagePickerScene(isCamera: false) else {
            return nil
        }
        let result = next.presenter
              
        let fillSelectedImage: (String) -> Observable<NewHoorayForm> = { imagePath in
            form.imagePath = imagePath
            return .just(form)
        }
        let throwWhenError: (Error) -> Observable<NewHoorayForm> = { error in
            return .error(error)
        }
        
        self.currentScene?.present(next, animated: true, completion: nil)
        
        return Observable
            .merge(result.selectedImagePath.flatMap(fillSelectedImage),
                   result.selectImageError.flatMap(throwWhenError))
    }
    
    public func openEnterHoorayMessageScene(_ form: NewHoorayForm,
                                            inputMode: TextInputMode) -> Observable<NewHoorayForm>? {
        
        guard let next = self.nextScenesBuilder?.makeTextInputScene(inputMode) else { return nil }
        next.modalPresentationStyle = .custom
        next.transitioningDelegate = self.bottomSliderTransitionManager
        next.setupDismissGesture(self.bottomSliderTransitionManager.dismissalInteractor)
        
        let fillMessage: (String) -> NewHoorayForm = { text in
            form.message = text
            return form
        }
        
        self.currentScene?.present(next, animated: true, completion: nil)
        
        return next.presenter?.enteredText.map(fillMessage)
    }
}
