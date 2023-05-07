//
//  FeedbackScene.swift
//  SettingScene
//
//  Created sudo.park on 2021/12/15.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - FeedbackScene Interactable & Listenable

public protocol FeedbackSceneInteractable: Sendable { }

public protocol FeedbackSceneListenable: AnyObject, Sendable { }


// MARK: - FeedbackScene

public protocol FeedbackScene: Scenable {
    
    nonisolated var interactor: FeedbackSceneInteractable? { get }
}


// MARK: - FeedbackViewModelImple conform FeedbackSceneInteractor

extension FeedbackViewModelImple: FeedbackSceneInteractable {

}


// MARK: - FeedbackViewController provide FeedbackSceneInteractor

extension FeedbackViewController {

    public nonisolated var interactor: FeedbackSceneInteractable? {
        return self.viewModel as? FeedbackSceneInteractable
    }
}
