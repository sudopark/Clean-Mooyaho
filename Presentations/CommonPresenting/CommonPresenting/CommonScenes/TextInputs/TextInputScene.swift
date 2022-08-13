//
//  TextInputScene.swift
//  CommonPresenting
//
//  Created sudo.park on 2021/06/12.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa


// MARK: - TextInputScene Interactor & Presenter

public protocol TextInputSceneInteractable: Sendable { }

public protocol TextInputSceneListenable: Sendable, AnyObject {
    
    func textInput(didEntered text: String?)
}

public final class DefaultTextInputListener: TextInputSceneListenable, Sendable {
    
    private let didEnterText = PublishSubject<String?>()
    public func textInput(didEntered text: String?) {
        return didEnterText.onNext(text)
    }
    
    public var enteredText: Observable<String?> {
        return self.didEnterText
    }
    
    public init() { }
    
    deinit {
        self.didEnterText.onCompleted()
    }
}



// MARK: - TextInputScene

public protocol TextInputScene: Scenable, PangestureDismissableScene {
    
    nonisolated var interactor: TextInputSceneInteractable? { get }
}


// MARK: - TextInputViewModelImple conform TextInputSceneInteractor or TextInputScenePresenter

extension TextInputViewModelImple: TextInputSceneInteractable {

}

// MARK: - TextInputViewController provide TextInputSceneInteractable

extension TextInputViewController {

    public nonisolated var interactor: TextInputSceneInteractable? {
        return self.viewModel as? TextInputSceneInteractable
    }
}
