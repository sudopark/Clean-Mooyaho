//
//  SharedMemberListScene.swift
//  DiscoveryScene
//
//  Created sudo.park on 2022/01/01.
//  Copyright © 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - SharedMemberListViewModelImple conform SharedMemberListSceneInteractor

extension SharedMemberListViewModelImple: SharedMemberListSceneInteractable {

}


// MARK: - SharedMemberListViewController provide SharedMemberListSceneInteractor

extension SharedMemberListViewController {

    public nonisolated var interactor: SharedMemberListSceneInteractable? {
        return self.viewModel as? SharedMemberListSceneInteractable
    }
}
