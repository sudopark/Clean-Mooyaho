//
//  NearbyScene.swift
//  LocationScenes
//
//  Created by sudo.park on 2021/06/04.
//

import UIKit

import RxSwift
import RxCocoa

import Domain
import CommonPresenting


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



extension NearbyViewModelImple: NearbySceneInteractor, NearbyScenePresenter {
    
    public var unavailToUseService: Observable<Void> {
        return self.alertUnavailToUseService
    }
}

extension NearbyViewController {
    
    public var interactor: NearbySceneInteractor? {
        return self.viewModel as? NearbySceneInteractor
    }
    
    public var presenter: NearbyScenePresenter? {
        return self.viewModel as? NearbyScenePresenter
    }
}
