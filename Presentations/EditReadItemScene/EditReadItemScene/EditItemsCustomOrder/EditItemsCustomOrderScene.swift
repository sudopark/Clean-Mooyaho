//
//  EditItemsCustomOrderScene.swift
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/15.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - EditItemsCustomOrderViewModelImple conform EditItemsCustomOrderSceneInteractor

extension EditItemsCustomOrderViewModelImple: EditItemsCustomOrderSceneInteractable {

}


// MARK: - EditItemsCustomOrderViewController provide EditItemsCustomOrderSceneInteractor

extension EditItemsCustomOrderViewController {

    public nonisolated var interactor: EditItemsCustomOrderSceneInteractable? {
        return self.viewModel as? EditItemsCustomOrderSceneInteractable
    }
}
