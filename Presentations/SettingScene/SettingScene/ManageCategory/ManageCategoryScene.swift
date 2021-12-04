//
//  ManageCategoryScene.swift
//  SettingScene
//
//  Created sudo.park on 2021/12/03.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - ManageCategoryScene Interactable & Listenable

public protocol ManageCategorySceneInteractable: EditCategoryAttrSceneListenable { }

public protocol ManageCategorySceneListenable: AnyObject { }


// MARK: - ManageCategoryScene

public protocol ManageCategoryScene: Scenable {
    
    var interactor: ManageCategorySceneInteractable? { get }
}


// MARK: - ManageCategoryViewModelImple conform ManageCategorySceneInteractor

extension ManageCategoryViewModelImple: ManageCategorySceneInteractable {

}


// MARK: - ManageCategoryViewController provide ManageCategorySceneInteractor

extension ManageCategoryViewController {

    public var interactor: ManageCategorySceneInteractable? {
        return self.viewModel as? ManageCategorySceneInteractable
    }
}
