//
//  SettingMainScene.swift
//  SettingScene
//
//  Created sudo.park on 2021/11/11.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - SettingMainViewModelImple conform SettingMainSceneInteractor

extension SettingMainViewModelImple: SettingMainSceneInteractable {

}


// MARK: - SettingMainViewController provide SettingMainSceneInteractor

extension SettingMainViewController {

    public var interactor: SettingMainSceneInteractable? {
        return self.viewModel as? SettingMainSceneInteractable
    }
}
