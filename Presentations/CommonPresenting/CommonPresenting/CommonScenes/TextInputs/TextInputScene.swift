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

@MainActor
public protocol TextInputSceneInteractable { }

@MainActor
public protocol TextInputSceneListenable: AnyObject {
    
    func textInput(didEntered text: String?)
}

public class DefaultTextInputListener: TextInputSceneListenable {
    
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
    
    var interactor: TextInputSceneInteractable? { get }
}


// MARK: - TextInputViewModelImple conform TextInputSceneInteractor or TextInputScenePresenter

extension TextInputViewModelImple: TextInputSceneInteractable {

}

// MARK: - TextInputViewController provide TextInputSceneInteractable

extension TextInputViewController {

    public var interactor: TextInputSceneInteractable? {
        return self.viewModel as? TextInputSceneInteractable
    }
}
