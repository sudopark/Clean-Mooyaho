//
//  Scenes+Hooray.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/06.
//

import Foundation

import RxSwift

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

public protocol MakeHooraySceneBuilable {
    
    func makeMakeHoorayScene() -> MakeHoorayScene
}


// MARK: - WaitNextHoorayScene Interactor & Presenter

//public protocol WaitNextHooraySceneInteractor { }
//
//public protocol WaitNextHoorayScenePresenter { }


// MARK: - WaitNextHoorayScene

public protocol WaitNextHoorayScene: Scenable, PangestureDismissableScene {
    
//    var interactor: WaitNextHooraySceneInteractor? { get }
//
//    var presenter: WaitNextHoorayScenePresenter? { get }
}

public protocol WaitNextHooraySceneBuilable {
    
    func makeWaitNextHoorayScene() -> WaitNextHoorayScene
}

