//
//  LocationSelectScene.swift
//  LocationScenes
//
//  Created sudo.park on 2021/06/12.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - LocationSelectViewModelImple conform LocationSelectSceneInteractor or LocationSelectScenePresenter

//extension LocationSelectViewModelImple: LocationSelectSceneInteractor {
//
//}
//
extension LocationSelectViewModelImple: LocationSelectScenePresenter {

}

// MARK: - LocationSelectViewController provide LocationSelectSceneInteractor or LocationSelectScenePresenter

extension LocationSelectViewController {

//    public var interactor: LocationSelectSceneInteractor? {
//        return self.viewModel as? LocationSelectSceneInteractor
//    }

    public var presenter: LocationSelectScenePresenter? {
        return self.viewModel as? LocationSelectScenePresenter
    }
}