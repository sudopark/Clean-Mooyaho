//
//  EnterHoorayMessageViewModel.swift
//  HoorayScene
//
//  Created sudo.park on 2021/06/07.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting

// MARK: - EnterHoorayMessageViewModel

public protocol EnterHoorayMessageViewModel: AnyObject {

    // interactor
    func updateText(_ text: String)
    func goNextInputStage()
    
    // presenter
    var previousInputText: String? { get }
    var isNextButtonEnabled: Observable<Bool> { get }
}


// MARK: - EnterHoorayMessageViewModelImple

public final class EnterHoorayMessageViewModelImple: EnterHoorayMessageViewModel {
    
    private let form: NewHoorayForm
    private let selectedImagePath: String?
    private let router: EnterHoorayMessageRouting
    
    public init(form: NewHoorayForm,
                selectedImagePath: String?,
        router: EnterHoorayMessageRouting) {
        self.form = form
        self.selectedImagePath = selectedImagePath
        self.router = router
        
        self.subjects.pendingInputText.accept(form.message)
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    fileprivate final class Subjects {
        let pendingInputText = BehaviorRelay<String?>(value: nil)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - EnterHoorayMessageViewModelImple Interactor

extension EnterHoorayMessageViewModelImple {
    
    public func updateText(_ text: String) {
        self.subjects.pendingInputText.accept(text)
    }
    
    public func goNextInputStage() {
        
        guard let message = self.subjects.pendingInputText.value, message.isNotEmpty else { return }
        form.message = message
        self.router.presentNextInputStage(form, selectedImage: self.selectedImagePath)
    }
}


// MARK: - EnterHoorayMessageViewModelImple Presenter

extension EnterHoorayMessageViewModelImple {
    
    public var previousInputText: String? {
        return self.form.message
    }
    
    public var isNextButtonEnabled: Observable<Bool> {
        return self.subjects.pendingInputText
            .map{ $0?.isNotEmpty == true }
            .distinctUntilChanged()
    }
}
