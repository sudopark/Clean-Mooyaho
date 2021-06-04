//
//  SignInScene.swift
//  MemberScenes
//
//  Created by sudo.park on 2021/06/04.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - SignInScene

public protocol SignInScenePresenter {
    
    var signedIn: Observable<Void> { get }
}

public protocol SignInScene: Scenable, PangestureDismissableScene {
    
    var presenter: SignInScenePresenter? { get }
}


extension SignInViewModelImple: SignInScenePresenter { }

extension SignInViewController {
    
    public var presenter: SignInScenePresenter? {
        return self.viewModel as? SignInScenePresenter
    }
}
