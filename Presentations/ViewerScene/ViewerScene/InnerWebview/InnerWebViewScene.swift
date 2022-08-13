//
//  InnerWebViewScene.swift
//  ViewerScene
//
//  Created sudo.park on 2021/10/04.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - InnerWebViewViewModelImple conform InnerWebViewSceneInteractable and InnerWebViewSceneOutput

extension InnerWebViewViewModelImple: InnerWebViewSceneInteractable {

}

// MARK: - InnerWebViewViewController provide InnerWebViewSceneInput and InnerWebViewSceneOutput

extension InnerWebViewViewController {

    public nonisolated var interactor: InnerWebViewSceneInteractable? {
        return self.viewModel as? InnerWebViewSceneInteractable
    }
}
