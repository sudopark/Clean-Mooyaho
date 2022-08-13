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


// MARK: - EditLinkItemViewModelImple conform EditLinkItemSceneInteractable

extension EditLinkItemViewModelImple: EditLinkItemSceneInteractable {

}

// MARK: - EditLinkItemViewController provide EditLinkItemSceneInput and EditLinkItemSceneOutput

extension EditLinkItemViewController {

    public nonisolated var interactor: EditLinkItemSceneInteractable? {
        return self.viewModel as? EditLinkItemSceneInteractable
    }
}
