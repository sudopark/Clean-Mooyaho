//
//  SearchNewPlaceScene.swift
//  PlaceScenes
//
//  Created sudo.park on 2021/06/11.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting



// MARK: - SearchNewPlaceViewModelImple conform SearchNewPlaceSceneInteractor or SearchNewPlaceScenePresenter

//extension SearchNewPlaceViewModelImple: SearchNewPlaceSceneInteractor {
//
//}
//
extension SearchNewPlaceViewModelImple: SearchNewPlaceSceneOutput { }

// MARK: - SearchNewPlaceViewController provide SearchNewPlaceSceneInteractor or SearchNewPlaceScenePresenter

extension SearchNewPlaceViewController {

    public var output: SearchNewPlaceSceneOutput? {
        return self.viewModel as? SearchNewPlaceSceneOutput
    }
}
