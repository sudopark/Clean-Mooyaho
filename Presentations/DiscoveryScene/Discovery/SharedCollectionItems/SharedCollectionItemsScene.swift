//
//  SharedCollectionItemsScene.swift
//  DiscoveryScene
//
//  Created sudo.park on 2021/11/16.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - SharedCollectionItemsViewModelImple conform SharedCollectionItemsSceneInteractor

extension SharedCollectionItemsViewModelImple: SharedCollectionItemsSceneInteractable {

}


// MARK: - SharedCollectionItemsViewController provide SharedCollectionItemsSceneInteractor

extension SharedCollectionItemsViewController {

    public nonisolated var interactor: SharedCollectionItemsSceneInteractable? {
        return self.viewModel as? SharedCollectionItemsSceneInteractable
    }
}
