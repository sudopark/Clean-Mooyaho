//
//  Scenes+Location.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/04.
//

import Foundation

import RxSwift

import Domain


// MARK: - NearbyScene

public protocol NearbySceneInteractor: AnyObject {
    
    func moveMapCameraToCurrentUserPosition()
}

public protocol NearbyScenePresenter {
    
    var currentPositionPlaceMark: Observable<String> { get }
    
    var unavailToUseService: Observable<Void> { get }
}

public protocol NearbyScene: Scenable {
    
    var interactor: NearbySceneInteractor? { get }
    
    var presenter: NearbyScenePresenter? { get }
}

public protocol NearbySceneBuilable {
    
    func makeNearbyScene() -> NearbyScene
}

// MARK: - LocationSelectScene Interactor & Presenter

//public protocol LocationSelectSceneInteractor { }
//
public protocol LocationSelectScenePresenter {
    
    var selectedLocation: Observable<CurrentPosition> { get }
}


// MARK: - LocationSelectScene

public protocol LocationSelectScene: Scenable {
    
//    var interactor: LocationSelectSceneInteractor? { get }
//
    var presenter: LocationSelectScenePresenter? { get }
}

public protocol LocationSelectSceneBuilable {
    
    func makeLocationSelectScene() -> LocationSelectScene
}


// MARK: - LocationMarkScene Interactor & Presenter

public protocol LocationMarkSceneInteractor {
    
    func updatePlaceMark(at coordinate: Coordinate)
}
//
//public protocol LocationMarkScenePresenter { }


// MARK: - LocationMarkScene

public protocol LocationMarkScene: Scenable {
    
    var interactor: LocationMarkSceneInteractor? { get }
//
//    var presenter: LocationMarkScenePresenter? { get }
}

public protocol LocationMarkSceneBuilable {
    
    func makeLocationMarkScene() -> LocationMarkScene
}
