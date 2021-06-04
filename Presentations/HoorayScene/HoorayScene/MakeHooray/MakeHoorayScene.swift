//
//  MakeHoorayScene.swift
//  HoorayScene
//
//  Created sudo.park on 2021/06/04.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting

// MARK: - MakeHoorayScene Interactor & Presenter

//public protocol MakeHooraySceneInteractor { }
//
//public protocol MakeHoorayScenePresenter { }


// MARK: - MakeHoorayScene

public protocol MakeHoorayScene: Scenable {
    
//    var interactor: MakeHooraySceneInteractor? { get }
//
//    var presenter: MakeHoorayScenePresenter? { get }
}


// MARK: - MakeHoorayViewModelImple conform MakeHooraySceneInteractor or MakeHoorayScenePresenter

//extension MakeHoorayViewModelImple: MakeHooraySceneInteractor {
//
//}
//
//extension MakeHoorayViewModelImple: MakeHoorayScenePresenter {
//
//}

// MARK: - MakeHoorayViewController provide MakeHooraySceneInteractor or MakeHoorayScenePresenter

//extension MakeHoorayViewController {
//
//    public var interactor: MakeHooraySceneInteractor? {
//        return self.viewModel as? MakeHooraySceneInteractor
//    }
//
//    public var presenter: MakeHoorayScenePresenter? {
//        return self.viewModel as? MakeHoorayScenePresenter
//    }
//}
