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

extension ReadCollectionViewItemsModelImple: ReadCollectionItemsSceneInput {
    
}

extension ReadCollectionViewItemsModelImple: ReadCollectionItemsSceneOutput {

}

// MARK: - ReadCollectionViewController provide ReadCollectionSceneInput and ReadCollectionSceneOutput

extension ReadCollectionItemsViewController {

    public var input: ReadCollectionItemsSceneInput? {
        return self.viewModel as? ReadCollectionItemsSceneInput
    }

    public var output: ReadCollectionItemsSceneOutput? {
        return self.viewModel as? ReadCollectionItemsSceneOutput
    }
}
