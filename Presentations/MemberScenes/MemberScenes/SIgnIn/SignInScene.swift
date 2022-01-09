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

extension SignInViewModelImple: SignInSceneInteractable { }

extension SignInViewController {
    
    public var interactor: SignInSceneInteractable? {
        return self.viewModel as? SignInSceneInteractable
    }
}
