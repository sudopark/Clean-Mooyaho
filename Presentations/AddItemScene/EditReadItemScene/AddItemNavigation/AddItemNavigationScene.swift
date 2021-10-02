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

extension AddItemNavigationViewModelImple: AddItemNavigationSceneInput {

}

extension AddItemNavigationViewModelImple: AddItemNavigationSceneOutput {

}

// MARK: - AddItemNavigationViewController provide AddItemNavigationSceneInput and AddItemNavigationSceneOutput

extension AddItemNavigationViewController {

    public var input: AddItemNavigationSceneInput? {
        return self.viewModel as? AddItemNavigationSceneInput
    }

    public var output: AddItemNavigationSceneOutput? {
        return self.viewModel as? AddItemNavigationSceneOutput
    }
}
