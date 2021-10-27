//
//  ShareMainScene.swift
//  MooyahoApp
//
//  Created sudo.park on 2021/10/28.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - ShareMainScene Interactable & Listenable

public protocol ShareMainSceneInteractable: EditLinkItemSceneListenable { }

public protocol ShareMainSceneListenable: AnyObject { }


// MARK: - ShareMainScene

public protocol ShareMainScene: Scenable {
    
    var interactor: ShareMainSceneInteractable? { get }
}


// MARK: - ShareMainViewModelImple conform ShareMainSceneInteractor

extension ShareMainViewModelImple: ShareMainSceneInteractable {

}


// MARK: - ShareMainViewController provide ShareMainSceneInteractor

extension ShareMainViewController {

    public var interactor: ShareMainSceneInteractable? {
        return self.viewModel as? ShareMainSceneInteractable
    }
}
