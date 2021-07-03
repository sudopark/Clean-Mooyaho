//
//  Scenes+Place.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/04.
//

import UIKit

import RxSwift

import Domain


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
public protocol SearchNewPlaceSceneOutput {
    
    var newRegistered: Observable<Place> { get }
}


// MARK: - SearchNewPlaceScene

public protocol SearchNewPlaceScene: Scenable {
    
//    var interactor: SearchNewPlaceSceneInteractor? { get }
//
    var output: SearchNewPlaceSceneOutput? { get }
}

public protocol SearchNewPlaceSceneBuilable {
    
    func makeSearchNewPlaceScene(myID: String) -> SearchNewPlaceScene
}


// MARK: - ManuallyResigterPlaceScene Interactor & Presenter

//public protocol ManuallyResigterPlaceSceneInteractor { }
//
public protocol ManuallyResigterPlaceSceneOutput { }


// MARK: - ManuallyResigterPlaceScene

public protocol ManuallyResigterPlaceScene: Scenable {
    
//    var interactor: ManuallyResigterPlaceSceneInteractor? { get }
    
    var output: ManuallyResigterPlaceSceneOutput? { get }
    
    var childContainerView: UIView { get }
}

public protocol ManuallyResigterPlaceSceneBuilable {
    
    func makeManuallyResigterPlaceScene(myID: String) -> ManuallyResigterPlaceScene
}
