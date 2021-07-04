//
//  ManuallyResigterPlaceScene.swift
//  PlaceScenes
//
//  Created sudo.park on 2021/06/12.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - ManuallyResigterPlaceViewModelImple conform ManuallyResigterPlaceSceneInteractor or ManuallyResigterPlaceScenePresenter

//extension ManuallyResigterPlaceViewModelImple: ManuallyResigterPlaceSceneInteractor {
//
//}
//
extension ManuallyResigterPlaceViewModelImple: ManuallyResigterPlaceSceneOutput { }

// MARK: - ManuallyResigterPlaceViewController provide ManuallyResigterPlaceSceneInteractor or ManuallyResigterPlaceScenePresenter

extension ManuallyResigterPlaceViewController {

    public var output: ManuallyResigterPlaceSceneOutput? {
        return self.viewModel as? ManuallyResigterPlaceSceneOutput
    }
}
