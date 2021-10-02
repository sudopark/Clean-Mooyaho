//
//  ReadCollectionMainScene.swift
//  ReadItemScene
//
//  Created sudo.park on 2021/10/02.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - ReadCollectionMainViewModelImple conform ReadCollectionMainSceneInput and ReadCollectionMainSceneOutput

extension ReadCollectionMainViewModelImple: ReadCollectionMainSceneInput {

}

extension ReadCollectionMainViewModelImple: ReadCollectionMainSceneOutput {

}

// MARK: - ReadCollectionMainViewController provide ReadCollectionMainSceneInput and ReadCollectionMainSceneOutput

extension ReadCollectionMainViewController {

    public var input: ReadCollectionMainSceneInput? {
        return self.viewModel as? ReadCollectionMainSceneInput
    }

    public var output: ReadCollectionMainSceneOutput? {
        return self.viewModel as? ReadCollectionMainSceneOutput
    }
}
