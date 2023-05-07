//
//  SharedCollectionInfoDialogScene.swift
//  DiscoveryScene
//
//  Created sudo.park on 2021/11/20.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - SharedCollectionInfoDialogViewModelImple conform SharedCollectionInfoDialogSceneInteractor

extension SharedCollectionInfoDialogViewModelImple: SharedCollectionInfoDialogSceneInteractable {

}


// MARK: - SharedCollectionInfoDialogViewController provide SharedCollectionInfoDialogSceneInteractor

extension SharedCollectionInfoDialogViewController {

    public nonisolated var interactor: SharedCollectionInfoDialogSceneInteractable? {
        return self.viewModel as? SharedCollectionInfoDialogSceneInteractable
    }
}
