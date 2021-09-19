//
//  ReadCollectionScene.swift
//  ReadItemScene
//
//  Created sudo.park on 2021/09/19.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - ReadCollectionViewModelImple conform ReadCollectionSceneInput and ReadCollectionSceneOutput

extension ReadCollectionViewModelImple: ReadCollectionSceneInput {

}

extension ReadCollectionViewModelImple: ReadCollectionSceneOutput {

}

// MARK: - ReadCollectionViewController provide ReadCollectionSceneInput and ReadCollectionSceneOutput

extension ReadCollectionViewController {

    public var input: ReadCollectionSceneInput? {
        return self.viewModel as? ReadCollectionSceneInput
    }

    public var output: ReadCollectionSceneOutput? {
        return self.viewModel as? ReadCollectionSceneOutput
    }
}
