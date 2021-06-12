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
    public let placeHolder: String?
    public let startWith: String?
    public let maxCharCount: Int?
    public let shouldEnterSomething: Bool
    public let defaultHeight: Float?
    
    public init(isSingleLine: Bool,
                placeHolder: String? = nil,
                startWith: String? = nil,
                maxCharCount: Int? = nil,
                shouldEnterSomething: Bool = false,
                defaultHeight: Float? = nil) {
        self.isSingleLine = isSingleLine
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
    
    // presenter
    var textInputMode: TextInputMode { get }
    var isConfirmable: Observable<Bool> { get }
    var enteredText: Observable<String> { get }
}


// MARK: - TextInputViewModelImple

public final class TextInputViewModelImple: TextInputViewModel {
    
    private let inputMode: TextInputMode
    private let router: TextInputRouting
    
    public init(inputMode: TextInputMode,
                router: TextInputRouting) {
        self.inputMode = inputMode
        self.router = router
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    fileprivate final class Subjects {
        let text = BehaviorRelay<String>(value: "")
        let confirmedText = PublishSubject<String>()
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - TextInputViewModelImple Interactor

extension TextInputViewModelImple {

    public func updateInput(text: String) {
        self.subjects.text.accept(text)
    }
    
    public func confirm() {
        let text = self.subjects.text.value
        
        let emitText: () -> Void = { [weak self] in
            self?.subjects.confirmedText.onNext(text)
        }
        
        self.router.closeScene(animated: true, completed: emitText)
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
    
    public var enteredText: Observable<String> {
        return self.subjects.confirmedText.asObservable()
    }
}