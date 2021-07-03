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
public protocol LocationSelectSceneOutput {
    
    var selectedLocation: Observable<CurrentPosition> { get }
}


// MARK: - LocationSelectScene

public protocol LocationSelectScene: Scenable {
    
//    var interactor: LocationSelectSceneInteractor? { get }
//
    var output: LocationSelectSceneOutput? { get }
}

public struct PreviousSelectedLocationInfo {
    public let latt: Double
    public let long: Double
    public let address: String
    
    public init(latt: Double, long: Double, address: String) {
        self.latt = latt
        self.long = long
        self.address = address
    }
}

public protocol LocationSelectSceneBuilable {
    
    func makeLocationSelectScene(_ previousInfo: PreviousSelectedLocationInfo?) -> LocationSelectScene
}


// MARK: - LocationMarkScene input & output

public protocol LocationMarkSceneInput {
    
    func updatePlaceMark(at coordinate: Coordinate)
}
//
//public protocol LocationMarkScenePresenter { }


// MARK: - LocationMarkScene

public protocol LocationMarkScene: Scenable {
    
    var input: LocationMarkSceneInput? { get }
//
//    var presenter: LocationMarkScenePresenter? { get }
}

public protocol LocationMarkSceneBuilable {
    
    func makeLocationMarkScene() -> LocationMarkScene
}
