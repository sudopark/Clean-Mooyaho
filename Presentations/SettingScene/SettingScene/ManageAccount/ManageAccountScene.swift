//
//  ManageAccountScene.swift
//  SettingScene
//
//  Created sudo.park on 2021/12/06.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - ManageAccountScene Interactable & Listenable

public protocol ManageAccountSceneInteractable: Sendable { }

public protocol ManageAccountSceneListenable: AnyObject, Sendable { }


// MARK: - ManageAccountScene

public protocol ManageAccountScene: Scenable {
    
    nonisolated var interactor: ManageAccountSceneInteractable? { get }
}


// MARK: - ManageAccountViewModelImple conform ManageAccountSceneInteractor

extension ManageAccountViewModelImple: ManageAccountSceneInteractable {

}


// MARK: - ManageAccountViewController provide ManageAccountSceneInteractor

extension ManageAccountViewController {

    public nonisolated var interactor: ManageAccountSceneInteractable? {
        return self.viewModel as? ManageAccountSceneInteractable
    }
}
