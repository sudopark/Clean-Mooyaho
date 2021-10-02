//
//  SelectAddItemTypeScene.swift
//  ReadItemScene
//
//  Created sudo.park on 2021/10/02.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - SelectAddItemTypeViewModelImple conform SelectAddItemTypeSceneInput and SelectAddItemTypeSceneOutput

extension SelectAddItemTypeViewModelImple: SelectAddItemTypeSceneInput {

}

extension SelectAddItemTypeViewModelImple: SelectAddItemTypeSceneOutput {

}

// MARK: - SelectAddItemTypeViewController provide SelectAddItemTypeSceneInput and SelectAddItemTypeSceneOutput

extension SelectAddItemTypeViewController {

    public var input: SelectAddItemTypeSceneInput? {
        return self.viewModel as? SelectAddItemTypeSceneInput
    }

    public var output: SelectAddItemTypeSceneOutput? {
        return self.viewModel as? SelectAddItemTypeSceneOutput
    }
}
