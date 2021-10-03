//
//  EditReadCollectionScene.swift
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/03.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - EditReadCollectionViewModelImple conform EditReadCollectionSceneInput and EditReadCollectionSceneOutput

extension EditReadCollectionViewModelImple: EditReadCollectionSceneInput {

}

extension EditReadCollectionViewModelImple: EditReadCollectionSceneOutput {

}

// MARK: - EditReadCollectionViewController provide EditReadCollectionSceneInput and EditReadCollectionSceneOutput

extension EditReadCollectionViewController {

    public var input: EditReadCollectionSceneInput? {
        return self.viewModel as? EditReadCollectionSceneInput
    }

    public var output: EditReadCollectionSceneOutput? {
        return self.viewModel as? EditReadCollectionSceneOutput
    }
}
