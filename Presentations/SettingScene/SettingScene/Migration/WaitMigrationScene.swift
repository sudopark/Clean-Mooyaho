//
//  WaitMigrationScene.swift
//  MooyahoApp
//
//  Created sudo.park on 2021/11/07.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - WaitMigrationViewModelImple conform WaitMigrationSceneInteractor

extension WaitMigrationViewModelImple: WaitMigrationSceneInteractable {

}


// MARK: - WaitMigrationViewController provide WaitMigrationSceneInteractor

extension WaitMigrationViewController {

    public nonisolated var interactor: WaitMigrationSceneInteractable? {
        return self.viewModel as? WaitMigrationSceneInteractable
    }
}
