//
//  StopShareCollectionScene.swift
//  DiscoveryScene
//
//  Created sudo.park on 2021/11/16.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - StopShareCollectionViewModelImple conform StopShareCollectionSceneInteractor

extension StopShareCollectionViewModelImple: StopShareCollectionSceneInteractable {

}


// MARK: - StopShareCollectionViewController provide StopShareCollectionSceneInteractor

extension StopShareCollectionViewController {

    public nonisolated var interactor: StopShareCollectionSceneInteractable? {
        return self.viewModel as? StopShareCollectionSceneInteractable
    }
}
