//
//  RecoverAccountScene.swift
//  MemberScenes
//
//  Created sudo.park on 2022/01/09.
//  Copyright © 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - RecoverAccountViewModelImple conform RecoverAccountSceneInteractor

extension RecoverAccountViewModelImple: RecoverAccountSceneInteractable {

}


// MARK: - RecoverAccountViewController provide RecoverAccountSceneInteractor

extension RecoverAccountViewController {

    public nonisolated var interactor: RecoverAccountSceneInteractable? {
        return self.viewModel as? RecoverAccountSceneInteractable
    }
}
