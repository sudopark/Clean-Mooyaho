//
//  EnterLinkURLScene.swift
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/02.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - EnterLinkURLViewModelImple conform EnterLinkURLSceneInput and EnterLinkURLSceneOutput

extension EnterLinkURLViewModelImple: EnterLinkURLSceneInput {

}

extension EnterLinkURLViewModelImple: EnterLinkURLSceneOutput {

}

// MARK: - EnterLinkURLViewController provide EnterLinkURLSceneInput and EnterLinkURLSceneOutput

extension EnterLinkURLViewController {

    public nonisolated var input: EnterLinkURLSceneInput? {
        return self.viewModel as? EnterLinkURLSceneInput
    }

    public nonisolated var output: EnterLinkURLSceneOutput? {
        return self.viewModel as? EnterLinkURLSceneOutput
    }
}
