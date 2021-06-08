//
//  SelectHoorayPlaceScene.swift
//  HoorayScene
//
//  Created sudo.park on 2021/06/08.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - SelectHoorayPlaceViewModelImple conform SelectHoorayPlaceSceneInteractor or SelectHoorayPlaceScenePresenter

extension SelectHoorayPlaceViewModelImple: EnteringNewHoorayPresenter {

}


// MARK: - SelectHoorayPlaceViewController provide SelectHoorayPlaceSceneInteractor or SelectHoorayPlaceScenePresenter

extension SelectHoorayPlaceViewController {

    public var presenter: EnteringNewHoorayPresenter? {
        return self.viewModel as? EnteringNewHoorayPresenter
    }
}
