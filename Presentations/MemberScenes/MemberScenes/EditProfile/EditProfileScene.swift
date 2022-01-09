//
//  EditProfileScene.swift
//  MemberScenes
//
//  Created by sudo.park on 2021/06/04.
//

import Foundation

import CommonPresenting


// MARK: - EditProfileScene Implement

extension EditProfileViewModelImple: EditProfileSceneInteractable { }


extension EditProfileViewController {
    
    public var interactor: EditProfileSceneInteractable? {
        return self.viewModel as? EditProfileSceneInteractable
    }
}
