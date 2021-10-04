//
//  EditReadPriorityScene.swift
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/04.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting

// MARK: - EditReadPriorityViewModelImple conform EditReadPrioritySceneInteractor

extension BaseEditReadPriorityViewModelImple: EditReadPrioritySceneInteractable {

}


// MARK: - EditReadPriorityViewController provide EditReadPrioritySceneInteractor

extension EditReadPriorityViewController {

    public var interactor: EditReadPrioritySceneInteractable? {
        return self.viewModel as? EditReadPrioritySceneInteractable
    }
}
