//
//  MemberProfileScene.swift
//  MemberScenes
//
//  Created sudo.park on 2021/12/11.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - MemberProfileViewModelImple conform MemberProfileSceneInteractor

extension MemberProfileViewModelImple: MemberProfileSceneInteractable {

}


// MARK: - MemberProfileViewController provide MemberProfileSceneInteractor

extension MemberProfileViewController {

    public nonisolated var interactor: MemberProfileSceneInteractable? {
        return self.viewModel as? MemberProfileSceneInteractable
    }
}
