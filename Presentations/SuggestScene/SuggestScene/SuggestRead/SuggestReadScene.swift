//
//  SuggestReadScene.swift
//  SuggestScene
//
//  Created sudo.park on 2021/11/27.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - SuggestReadViewModelImple conform SuggestReadSceneInteractor

extension SuggestReadViewModelImple: SuggestReadSceneInteractable {

}


// MARK: - SuggestReadViewController provide SuggestReadSceneInteractor

extension SuggestReadViewController {

    public var interactor: SuggestReadSceneInteractable? {
        return self.viewModel as? SuggestReadSceneInteractable
    }
}
