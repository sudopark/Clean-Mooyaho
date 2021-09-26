//
//  AddReadLinkScene.swift
//  ReadItemScene
//
//  Created sudo.park on 2021/09/26.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting

// MARK: - AddReadLinkViewModelImple conform AddReadLinkSceneInput and AddReadLinkSceneOutput

extension AddReadLinkViewModelImple: AddReadLinkSceneInput {

}

extension AddReadLinkViewModelImple: AddReadLinkSceneOutput {

}

// MARK: - AddReadLinkViewController provide AddReadLinkSceneInput and AddReadLinkSceneOutput

extension AddReadLinkViewController {

    public var input: AddReadLinkSceneInput? {
        return self.viewModel as? AddReadLinkSceneInput
    }

    public var output: AddReadLinkSceneOutput? {
        return self.viewModel as? AddReadLinkSceneOutput
    }
}
