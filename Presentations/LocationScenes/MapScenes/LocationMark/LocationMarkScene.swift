//
//  LocationMarkScene.swift
//  MapScenes
//
//  Created sudo.park on 2021/06/12.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - LocationMarkViewModelImple conform LocationMarkSceneInteractor or LocationMarkScenePresenter

extension LocationMarkViewModelImple: LocationMarkSceneInput {

}
//
//extension LocationMarkViewModelImple: LocationMarkScenePresenter {
//
//}

// MARK: - LocationMarkViewController provide LocationMarkSceneInteractor or LocationMarkScenePresenter

extension LocationMarkViewController {
    
    public var input: LocationMarkSceneInput? {
        return self.viewModel as? LocationMarkSceneInput
    }

//    public var presenter: LocationMarkScenePresenter? {
//        return self.viewModel as? LocationMarkScenePresenter
//    }
}
