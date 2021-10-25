//
//  NavigateCollectionScene.swift
//  ReadItemScene
//
//  Created sudo.park on 2021/10/26.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - NavigateCollectionViewModelImple conform NavigateCollectionSceneInteractor

extension NavigateCollectionViewModelImple: NavigateCollectionSceneInteractable {

}


// MARK: - NavigateCollectionViewController provide NavigateCollectionSceneInteractor

extension NavigateCollectionViewController {

    public var interactor: NavigateCollectionSceneInteractable? {
        return self.viewModel as? NavigateCollectionSceneInteractable
    }
}
