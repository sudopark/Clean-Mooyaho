//
//  EditLinkItemScene.swift
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/03.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - EditLinkItemViewModelImple conform EditLinkItemSceneInput and EditLinkItemSceneOutput

extension EditLinkItemViewModelImple: EditLinkItemSceneInput {

}

extension EditLinkItemViewModelImple: EditLinkItemSceneOutput {

}

// MARK: - EditLinkItemViewController provide EditLinkItemSceneInput and EditLinkItemSceneOutput

extension EditLinkItemViewController {

    public var input: EditLinkItemSceneInput? {
        return self.viewModel as? EditLinkItemSceneInput
    }

    public var output: EditLinkItemSceneOutput? {
        return self.viewModel as? EditLinkItemSceneOutput
    }
}
