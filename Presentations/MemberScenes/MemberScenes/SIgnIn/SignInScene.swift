//
//  SignInScene.swift
//  MemberScenes
//
//  Created by sudo.park on 2021/06/04.
//

import Foundation

import RxSwift

import CommonPresenting


// MARK: - SignInScene Implement

extension SignInViewModelImple: SignInScenePresenter { }

extension SignInViewController {
    
    public var presenter: SignInScenePresenter? {
        return self.viewModel as? SignInScenePresenter
    }
}
