//
//  Scenes+Location.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/04.
//

import Foundation

import RxSwift


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
