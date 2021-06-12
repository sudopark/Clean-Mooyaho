//
//  TextInputScene.swift
//  CommonPresenting
//
//  Created sudo.park on 2021/06/12.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa


// MARK: - TextInputScene Interactor & Presenter

//public protocol TextInputSceneInteractor { }
//
public protocol TextInputScenePresenter {
    var enteredText: Observable<String> { get }
}


// MARK: - TextInputScene

public protocol TextInputScene: Scenable, PangestureDismissableScene {
    
//    var interactor: TextInputSceneInteractor? { get }
//
    var presenter: TextInputScenePresenter? { get }
}


// MARK: - TextInputViewModelImple conform TextInputSceneInteractor or TextInputScenePresenter

//extension TextInputViewModelImple: TextInputSceneInteractor {
//
//}
//
extension TextInputViewModelImple: TextInputScenePresenter {

}

// MARK: - TextInputViewController provide TextInputSceneInteractor or TextInputScenePresenter

extension TextInputViewController {

//    public var interactor: TextInputSceneInteractor? {
//        return self.viewModel as? TextInputSceneInteractor
//    }
//
    public var presenter: TextInputScenePresenter? {
        return self.viewModel as? TextInputScenePresenter
    }
}
