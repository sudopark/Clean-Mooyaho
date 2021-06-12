//
//  Scenes+Hooray.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/06.
//

import UIKit

import RxSwift

import Domain

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
    
    func makeEnterHoorayImageScene(form: NewHoorayForm) -> EnterHoorayImageScene
    
    func makeEnterHoorayMessageScene(form: NewHoorayForm) -> EnterHoorayMessageScene
    
    func makeEnterHoorayTagScene(form: NewHoorayForm) -> EnterHoorayTagScene
    
    func makeSelectHoorayPlaceScene(form: NewHoorayForm) -> SelectHoorayPlaceScene
}


// MARK: - Enter new Hooray

public protocol EnteringNewHoorayPresenter {
    
    var goNextStepWithForm: Observable<NewHoorayForm> { get }
}

public protocol BaseEnterNewHoorayInfoScene: Scenable {
    
    var presenter: EnteringNewHoorayPresenter? { get }
}

// MARK: - EnterHoorayImageScene

public protocol EnterHoorayImageScene: BaseEnterNewHoorayInfoScene, PangestureDismissableScene { }

// MARK: - EnterHoorayMessageScene

public protocol EnterHoorayMessageScene: BaseEnterNewHoorayInfoScene, PangestureDismissableScene { }

// MARK: - EnterHoorayTagScene

public protocol EnterHoorayTagScene: BaseEnterNewHoorayInfoScene, PangestureDismissableScene { }

// MARK: - SelectHoorayPlaceScene

public protocol SelectHoorayPlaceScene: BaseEnterNewHoorayInfoScene { }


// MARK: - WaitNextHoorayScene

public protocol WaitNextHoorayScene: Scenable, PangestureDismissableScene {
    
//    var interactor: WaitNextHooraySceneInteractor? { get }
//
//    var presenter: WaitNextHoorayScenePresenter? { get }
}

public protocol WaitNextHooraySceneBuilable {
    
    func makeWaitNextHoorayScene(_ waitUntil: TimeStamp) -> WaitNextHoorayScene
}
