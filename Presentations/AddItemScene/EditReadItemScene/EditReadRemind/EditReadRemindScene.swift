//
//  EditReadRemindScene.swift
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/22.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - EditReadRemindViewModelImple conform EditReadRemindSceneInteractor

extension EditReadRemindViewModelImple: EditReadRemindSceneInteractable {

}


// MARK: - EditReadRemindViewController provide EditReadRemindSceneInteractor

extension EditReadRemindViewController {

    public var interactor: EditReadRemindSceneInteractable? {
        return self.viewModel as? EditReadRemindSceneInteractable
    }
}
