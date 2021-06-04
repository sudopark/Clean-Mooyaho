//
//  EditProfileScene.swift
//  MemberScenes
//
//  Created by sudo.park on 2021/06/04.
//

import Foundation

import CommonPresenting


// MARK: - EditProfileScene Implement

extension EditProfileViewModelImple: EditProfileScenePresenter { }


extension EditProfileViewController {
    
    public var presenrer: EditProfileScenePresenter? {
        return self.viewModel as? EditProfileScenePresenter
    }
}
