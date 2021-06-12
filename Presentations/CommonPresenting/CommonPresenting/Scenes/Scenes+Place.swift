//
//  Scenes+Place.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/04.
//

import Foundation


// MARK: - RegisterNewPlaceScene Interactor & Presenter

//public protocol RegisterNewPlaceSceneInteractor { }
//
//public protocol RegisterNewPlaceScenePresenter { }


// MARK: - RegisterNewPlaceScene

public protocol RegisterNewPlaceScene: Scenable {
    
//    var interactor: RegisterNewPlaceSceneInteractor? { get }
//
//    var presenter: RegisterNewPlaceScenePresenter? { get }
}


public protocol RegisterNewPlaceSceneBuilable {
    
    func makeRegisterNewPlaceScene() -> RegisterNewPlaceScene
}


// MARK: - SearchNewPlaceScene Interactor & Presenter

//public protocol SearchNewPlaceSceneInteractor { }
//
//public protocol SearchNewPlaceScenePresenter { }


// MARK: - SearchNewPlaceScene

public protocol SearchNewPlaceScene: Scenable {
    
//    var interactor: SearchNewPlaceSceneInteractor? { get }
//
//    var presenter: SearchNewPlaceScenePresenter? { get }
}

public protocol SearchNewPlaceSceneBuilable {
    
    func makeSearchNewPlaceScene(myID: String) -> SearchNewPlaceScene
}


// MARK: - ManuallyResigterPlaceScene Interactor & Presenter

//public protocol ManuallyResigterPlaceSceneInteractor { }
//
//public protocol ManuallyResigterPlaceScenePresenter { }


// MARK: - ManuallyResigterPlaceScene

public protocol ManuallyResigterPlaceScene: Scenable {
    
//    var interactor: ManuallyResigterPlaceSceneInteractor? { get }
//
//    var presenter: ManuallyResigterPlaceScenePresenter? { get }
}

public protocol ManuallyResigterPlaceSceneBuilable {
    
    func makeManuallyResigterPlaceScene(myID: String) -> ManuallyResigterPlaceScene
}
