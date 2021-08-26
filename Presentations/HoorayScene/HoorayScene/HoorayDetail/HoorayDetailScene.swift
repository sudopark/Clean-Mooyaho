//
//  HoorayDetailScene.swift
//  HoorayScene
//
//  Created sudo.park on 2021/08/26.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting

// MARK: - HoorayDetailViewModelImple conform HoorayDetailSceneInput and HoorayDetailSceneOutput

extension HoorayDetailViewModelImple: HoorayDetailSceneInput {

}

extension HoorayDetailViewModelImple: HoorayDetailSceneOutput {

}

// MARK: - HoorayDetailViewController provide HoorayDetailSceneInput and HoorayDetailSceneOutput

extension HoorayDetailViewController {

    public var input: HoorayDetailSceneInput? {
        return self.viewModel as? HoorayDetailSceneInput
    }

    public var output: HoorayDetailSceneOutput? {
        return self.viewModel as? HoorayDetailSceneOutput
    }
}
