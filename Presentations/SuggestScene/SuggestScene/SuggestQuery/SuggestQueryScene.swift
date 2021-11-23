//
//  SuggestQueryScene.swift
//  SuggestScene
//
//  Created sudo.park on 2021/11/23.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - SuggestQueryViewModelImple conform SuggestQuerySceneInteractor

extension SuggestQueryViewModelImple: SuggestQuerySceneInteractable {

}


// MARK: - SuggestQueryViewController provide SuggestQuerySceneInteractor

extension SuggestQueryViewController {

    public var interactor: SuggestQuerySceneInteractable? {
        return self.viewModel as? SuggestQuerySceneInteractable
    }
}
