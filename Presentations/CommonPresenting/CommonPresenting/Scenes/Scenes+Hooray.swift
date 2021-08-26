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


// MARK: - HoorayDetailScene Input & Output

public protocol HoorayDetailSceneInput { }

public protocol HoorayDetailSceneOutput { }


// MARK: - HoorayDetailScene

public protocol HoorayDetailScene: Scenable {
    
    var input: HoorayDetailSceneInput? { get }

    var output: HoorayDetailSceneOutput? { get }
}
