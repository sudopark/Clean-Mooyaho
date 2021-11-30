//
//  FavoriteItemsScene.swift
//  ReadItemScene
//
//  Created sudo.park on 2021/12/01.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - FavoriteItemsViewModelImple conform FavoriteItemsSceneInteractor

extension FavoriteItemsViewModelImple: FavoriteItemsSceneInteractable {

}


// MARK: - FavoriteItemsViewController provide FavoriteItemsSceneInteractor

extension FavoriteItemsViewController {

    public var interactor: FavoriteItemsSceneInteractable? {
        return self.viewModel as? FavoriteItemsSceneInteractable
    }
}
