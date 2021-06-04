//
//  EditProfileScene.swift
//  MemberScenes
//
//  Created by sudo.park on 2021/06/04.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - EditProfileScene

public protocol EditProfileScenePresenter {
    
    var editCompleted: Observable<Void> { get }
}

public protocol EditProfileScene: Scenable {
    
    var presenrer: EditProfileScenePresenter? { get }
}


extension EditProfileViewModelImple: EditProfileScenePresenter { }


extension EditProfileViewController {
    
    public var presenrer: EditProfileScenePresenter? {
        return self.viewModel as? EditProfileScenePresenter
    }
}
