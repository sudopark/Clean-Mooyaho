//
//  EnterHoorayMessageScene.swift
//  HoorayScene
//
//  Created sudo.park on 2021/06/07.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - EnterHoorayMessageViewModelImple conform EnterHoorayMessageSceneInteractor or EnterHoorayMessageScenePresenter

extension EnterHoorayMessageViewModelImple: EnteringNewHoorayPresenter {

}


// MARK: - EnterHoorayMessageViewController provide EnterHoorayMessageSceneInteractor or EnterHoorayMessageScenePresenter

extension EnterHoorayMessageViewController {

    public var presenter: EnteringNewHoorayPresenter? {
        return self.viewModel as? EnteringNewHoorayPresenter
    }
}
