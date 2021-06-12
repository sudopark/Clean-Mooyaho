//
//  LocationMarkScene.swift
//  LocationScenes
//
//  Created sudo.park on 2021/06/12.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - LocationMarkViewModelImple conform LocationMarkSceneInteractor or LocationMarkScenePresenter

extension LocationMarkViewModelImple: LocationMarkSceneInteractor {

}
//
//extension LocationMarkViewModelImple: LocationMarkScenePresenter {
//
//}

// MARK: - LocationMarkViewController provide LocationMarkSceneInteractor or LocationMarkScenePresenter

extension LocationMarkViewController {

    public var interactor: LocationMarkSceneInteractor? {
        return self.viewModel as? LocationMarkSceneInteractor
    }

//    public var presenter: LocationMarkScenePresenter? {
//        return self.viewModel as? LocationMarkScenePresenter
//    }
}
