//
//  TextInputViewModel.swift
//  CommonPresenting
//
//  Created sudo.park on 2021/06/12.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain


public struct TextInputMode {
    
    public let isSingleLine: Bool
    public let title: String
    public var placeHolder: String?
    public var startWith: String?
    public var maxCharCount: Int?
    public var shouldEnterSomething: Bool
    public var defaultHeight: Float?
    
    public init(isSingleLine: Bool,
                title: String,
                placeHolder: String? = nil,
                startWith: String? = nil,
                maxCharCount: Int? = nil,
                shouldEnterSomething: Bool = false,
                defaultHeight: Float? = nil) {
        self.isSingleLine = isSingleLine
        self.title = title
        self.placeHolder = placeHolder
        self.startWith = startWith
        self.maxCharCount = maxCharCount
        self.shouldEnterSomething = shouldEnterSomething
        self.defaultHeight = defaultHeight
    }
}

// MARK: - TextInputViewModel

public protocol TextInputViewModel: AnyObject {

    // interactor
    func updateInput(text: String)
    func confirm()
    func close()
    
    // presenter
    var textInputMode: TextInputMode { get }
    var isConfirmable: Observable<Bool> { get }
}


// MARK: - TextInputViewModelImple

public final class TextInputViewModelImple: TextInputViewModel {
    
    private let inputMode: TextInputMode
    private let router: TextInputRouting
    private weak var listener: TextInputSceneListenable?
    
    public init(inputMode: TextInputMode,
                router: TextInputRouting,
                listener: TextInputSceneListenable?) {
        self.inputMode = inputMode
        self.router = router
        self.listener = listener
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    fileprivate final class Subjects {
        let text = BehaviorRelay<String>(value: "")
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - TextInputViewModelImple Interactor

extension TextInputViewModelImple {

    public func updateInput(text: String) {
        self.subjects.text.accept(text)
    }
    
    public func close() {
        self.router.closeScene(animated: true, completed: nil)
    }
    
    public func confirm() {
        let text = self.subjects.text.value
        self.router.closeScene(animated: true) { [weak self] in
            self?.listener?.textInput(didEntered: text)
        }
    }
}


// MARK: - TextInputViewModelImple Presenter

extension TextInputViewModelImple {
    
    public var textInputMode: TextInputMode {
        return self.inputMode
    }
    
    public var isConfirmable: Observable<Bool> {
        let shouldNotEmpty = self.inputMode.shouldEnterSomething
        return self.subjects.text
            .map { text in
                return shouldNotEmpty ? text.isNotEmpty : true
            }
            .distinctUntilChanged()
    }
}
