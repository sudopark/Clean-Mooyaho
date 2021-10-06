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

extension EditReadCollectionViewModelImple: EditReadCollectionSceneInteractable {

}

// MARK: - EditReadCollectionViewController provide EditReadCollectionSceneInput and EditReadCollectionSceneOutput

extension EditReadCollectionViewController {

    public var interactor: EditReadCollectionSceneInteractable? {
        return self.viewModel as? EditReadCollectionSceneInteractable
    }
}
