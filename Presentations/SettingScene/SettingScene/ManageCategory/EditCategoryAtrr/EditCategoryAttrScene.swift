//
//  EditCategoryAttrScene.swift
//  SettingScene
//
//  Created sudo.park on 2021/12/04.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - EditCategoryAttrScene Interactable & Listenable

public protocol EditCategoryAttrSceneInteractable { }

public protocol EditCategoryAttrSceneListenable: AnyObject { }


// MARK: - EditCategoryAttrScene

public protocol EditCategoryAttrScene: Scenable {
    
    var interactor: EditCategoryAttrSceneInteractable? { get }
}


// MARK: - EditCategoryAttrViewModelImple conform EditCategoryAttrSceneInteractor

extension EditCategoryAttrViewModelImple: EditCategoryAttrSceneInteractable {

}


// MARK: - EditCategoryAttrViewController provide EditCategoryAttrSceneInteractor

extension EditCategoryAttrViewController {

    public var interactor: EditCategoryAttrSceneInteractable? {
        return self.viewModel as? EditCategoryAttrSceneInteractable
    }
}
