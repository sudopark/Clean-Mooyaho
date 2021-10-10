//
//  ColorSelectScene.swift
//  CommonPresenting
//
//  Created sudo.park on 2021/10/11.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa


// MARK: - ColorSelectScene Interactable & Listenable

public protocol ColorSelectSceneInteractable { }

public protocol ColorSelectSceneListenable: AnyObject {
    
    func colorSelect(didSeelctColor hexCode: String)
}


// MARK: - ColorSelectScene

public protocol ColorSelectScene: Scenable, PangestureDismissableScene {
    
    var interactor: ColorSelectSceneInteractable? { get }
}


// MARK: - ColorSelectViewModelImple conform ColorSelectSceneInteractor

extension ColorSelectViewModelImple: ColorSelectSceneInteractable {

}


// MARK: - ColorSelectViewController provide ColorSelectSceneInteractor

extension ColorSelectViewController {

    public var interactor: ColorSelectSceneInteractable? {
        return self.viewModel as? ColorSelectSceneInteractable
    }
}
