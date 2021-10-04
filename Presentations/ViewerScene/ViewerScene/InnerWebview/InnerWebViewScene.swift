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


// MARK: - InnerWebViewViewModelImple conform InnerWebViewSceneInput and InnerWebViewSceneOutput

extension InnerWebViewViewModelImple: InnerWebViewSceneInput {

}

extension InnerWebViewViewModelImple: InnerWebViewSceneOutput {

}

// MARK: - InnerWebViewViewController provide InnerWebViewSceneInput and InnerWebViewSceneOutput

extension InnerWebViewViewController {

    public var input: InnerWebViewSceneInput? {
        return self.viewModel as? InnerWebViewSceneInput
    }

    public var output: InnerWebViewSceneOutput? {
        return self.viewModel as? InnerWebViewSceneOutput
    }
}
