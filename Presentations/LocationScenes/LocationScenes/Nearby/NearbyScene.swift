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


// MARK: - NearbyScene Implement

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
