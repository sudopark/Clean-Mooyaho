//
//  AllSharedCollectionsScene.swift
//  DiscoveryScene
//
//  Created sudo.park on 2021/12/08.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - AllSharedCollectionsScene Interactable & Listenable

public protocol AllSharedCollectionsSceneInteractable { }

public protocol AllSharedCollectionsSceneListenable: AnyObject { }


// MARK: - AllSharedCollectionsScene

public protocol AllSharedCollectionsScene: Scenable {
    
    var interactor: AllSharedCollectionsSceneInteractable? { get }
}


// MARK: - AllSharedCollectionsViewModelImple conform AllSharedCollectionsSceneInteractor

extension AllSharedCollectionsViewModelImple: AllSharedCollectionsSceneInteractable {

}


// MARK: - AllSharedCollectionsViewController provide AllSharedCollectionsSceneInteractor

extension AllSharedCollectionsViewController {

    public var interactor: AllSharedCollectionsSceneInteractable? {
        return self.viewModel as? AllSharedCollectionsSceneInteractable
    }
}
