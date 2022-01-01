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


// MARK: - SharedMemberListScene Interactable & Listenable

public protocol SharedMemberListSceneInteractable { }

public protocol SharedMemberListSceneListenable: AnyObject { }


// MARK: - SharedMemberListScene

public protocol SharedMemberListScene: Scenable {
    
    var interactor: SharedMemberListSceneInteractable? { get }
}


// MARK: - SharedMemberListViewModelImple conform SharedMemberListSceneInteractor

extension SharedMemberListViewModelImple: SharedMemberListSceneInteractable {

}


// MARK: - SharedMemberListViewController provide SharedMemberListSceneInteractor

extension SharedMemberListViewController {

    public var interactor: SharedMemberListSceneInteractable? {
        return self.viewModel as? SharedMemberListSceneInteractable
    }
}
