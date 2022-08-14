//
//  IntegratedSearchScene.swift
//  SuggestScene
//
//  Created sudo.park on 2021/11/23.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - IntegratedSearchViewModelImple conform IntegratedSearchSceneInteractor

extension IntegratedSearchViewModelImple: IntegratedSearchSceneInteractable {

}


// MARK: - IntegratedSearchViewController provide IntegratedSearchSceneInteractor

extension IntegratedSearchViewController {

    public nonisolated var interactor: IntegratedSearchSceneInteractable? {
        return self.viewModel as? IntegratedSearchSceneInteractable
    }
}
