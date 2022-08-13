//
//  LinkMemoScene.swift
//  ViewerScene
//
//  Created sudo.park on 2021/10/24.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - LinkMemoViewModelImple conform LinkMemoSceneInteractor

extension LinkMemoViewModelImple: LinkMemoSceneInteractable {

}


// MARK: - LinkMemoViewController provide LinkMemoSceneInteractor

extension LinkMemoViewController {

    public nonisolated var interactor: LinkMemoSceneInteractable? {
        return self.viewModel as? LinkMemoSceneInteractable
    }
}
