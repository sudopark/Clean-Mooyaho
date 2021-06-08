//
//  EnterHoorayImageScene.swift
//  HoorayScene
//
//  Created sudo.park on 2021/06/06.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting

// MARK: - EnterHoorayImageViewModelImple conform EnterHoorayImageSceneInteractor or EnterHoorayImageScenePresenter

extension EnterHoorayImageViewModelImple: EnteringNewHoorayPresenter {

}

// MARK: - EnterHoorayImageViewController provide EnterHoorayImageSceneInteractor or EnterHoorayImageScenePresenter

extension EnterHoorayImageViewController {
    
    public var presenter: EnteringNewHoorayPresenter? {
        return self.viewModel as? EnteringNewHoorayPresenter
    }
}
