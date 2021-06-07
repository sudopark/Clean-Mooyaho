//
//  Scenes+Hooray.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/06.
//

import Foundation

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
    
    func makeEnterHoorayImageScene(form: NewHoorayForm,
                                   previousSelectImagePath: String?,
                                   transitionManager: BottomSlideTransitionAnimationManager?) -> EnterHoorayImageScene
    
    func makeEnterHoorayMessageScene(form: NewHoorayForm,
                                     previousSelectImagePath: String?,
                                     transitionManager: BottomSlideTransitionAnimationManager?) -> EnterHoorayMessageScene
    
    func makeEnterHoorayTagScene(form: NewHoorayForm, previousSelectImagePath: String?) -> EnterHoorayTagScene
    
    func makeSelectHoorayPlaceScene(form: NewHoorayForm, previousSelectImagePath: String?) -> SelectHoorayPlaceScene
}


// MARK: - WaitNextHoorayScene Interactor & Presenter

//public protocol WaitNextHooraySceneInteractor { }
//
//public protocol WaitNextHoorayScenePresenter { }


// MARK: - EnterHoorayImageScene Interactor & Presenter

//public protocol EnterHoorayImageSceneInteractor { }
//
//public protocol EnterHoorayImageScenePresenter { }


// MARK: - EnterHoorayImageScene

public protocol EnterHoorayImageScene: Scenable, PangestureDismissableScene {
    
//    var interactor: EnterHoorayImageSceneInteractor? { get }
//
//    var presenter: EnterHoorayImageScenePresenter? { get }
}


// MARK: - EnterHoorayMessageScene Interactor & Presenter

//public protocol EnterHoorayMessageSceneInteractor { }
//
//public protocol EnterHoorayMessageScenePresenter { }


// MARK: - EnterHoorayMessageScene

public protocol EnterHoorayMessageScene: Scenable, PangestureDismissableScene {
    
//    var interactor: EnterHoorayMessageSceneInteractor? { get }
//
//    var presenter: EnterHoorayMessageScenePresenter? { get }
}


// MARK: - EnterHoorayTagScene Interactor & Presenter

//public protocol EnterHoorayTagSceneInteractor { }
//
//public protocol EnterHoorayTagScenePresenter { }


// MARK: - EnterHoorayTagScene

public protocol EnterHoorayTagScene: Scenable, PangestureDismissableScene {
    
//    var interactor: EnterHoorayTagSceneInteractor? { get }
//
//    var presenter: EnterHoorayTagScenePresenter? { get }
}

// MARK: - SelectHoorayPlaceScene Interactor & Presenter

//public protocol SelectHoorayPlaceSceneInteractor { }
//
//public protocol SelectHoorayPlaceScenePresenter { }


// MARK: - SelectHoorayPlaceScene

public protocol SelectHoorayPlaceScene: Scenable {
    
//    var interactor: SelectHoorayPlaceSceneInteractor? { get }
//
//    var presenter: SelectHoorayPlaceScenePresenter? { get }
}


// MARK: - WaitNextHoorayScene

public protocol WaitNextHoorayScene: Scenable, PangestureDismissableScene {
    
//    var interactor: WaitNextHooraySceneInteractor? { get }
//
//    var presenter: WaitNextHoorayScenePresenter? { get }
}

public protocol WaitNextHooraySceneBuilable {
    
    func makeWaitNextHoorayScene(_ waitUntil: TimeStamp) -> WaitNextHoorayScene
}

