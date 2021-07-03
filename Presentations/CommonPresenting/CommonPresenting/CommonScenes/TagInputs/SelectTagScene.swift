//
//  SelectTagScene.swift
//  CommonPresenting
//
//  Created sudo.park on 2021/06/12.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import Domain


// MARK: - SelectTagScene Interactor & Presenter

//public protocol SelectTagSceneInteractor { }
//
public protocol SelectTagSceneOutput {
    
    var selectedTags: Observable<[Tag]> { get }
}


// MARK: - SelectTagScene

public protocol SelectTagScene: Scenable, PangestureDismissableScene {
    
//    var interactor: SelectTagSceneInteractor? { get }
//
    var presenter: SelectTagSceneOutput? { get }
}


// MARK: - SelectTagViewModelImple conform SelectTagSceneInteractor or SelectTagScenePresenter

//extension SelectTagViewModelImple: SelectTagSceneInteractor {
//
//}
//
extension SelectTagViewModelImple: SelectTagSceneOutput { }
//
// MARK: - SelectTagViewController provide SelectTagSceneInteractor or SelectTagScenePresenter
//
extension SelectTagViewController {
//
//    public var interactor: SelectTagSceneInteractor? {
//        return self.viewModel as? SelectTagSceneInteractor
//    }
//
    public var presenter: SelectTagSceneOutput? {
        return self.viewModel as? SelectTagSceneOutput
    }
}
