//
//  AddItemNavigationScene.swift
//  AddItemScene
//
//  Created sudo.park on 2021/10/02.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - AddItemNavigationViewModelImple conform AddItemNavigationSceneInput and AddItemNavigationSceneOutput

extension AddItemNavigationViewModelImple: AddItemNavigationSceneInteractable {

}

// MARK: - AddItemNavigationViewController provide AddItemNavigationSceneInput and AddItemNavigationSceneOutput

extension AddItemNavigationViewController {

    public var interactor: AddItemNavigationSceneInteractable? {
        return self.viewModel as? AddItemNavigationSceneInteractable
    }
}
