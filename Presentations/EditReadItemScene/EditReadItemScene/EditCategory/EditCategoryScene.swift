//
//  EditCategoryScene.swift
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/08.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - EditCategoryViewModelImple conform EditCategorySceneInteractor

extension EditCategoryViewModelImple: EditCategorySceneInteractable {

}


// MARK: - EditCategoryViewController provide EditCategorySceneInteractor

extension EditCategoryViewController {

    public nonisolated var interactor: EditCategorySceneInteractable? {
        return self.viewModel as? EditCategorySceneInteractable
    }
}
