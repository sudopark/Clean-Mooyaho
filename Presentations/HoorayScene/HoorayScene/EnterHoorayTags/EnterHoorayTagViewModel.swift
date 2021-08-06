//
//  EnterHoorayTagViewModel.swift
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


// MARK: - EnterHoorayTagViewModel

public protocol EnterHoorayTagViewModel: AnyObject {

    // interactor
    func close()
    func goNextInputStage(with tags: [String])
    
    // presenter
    var previousInputTags: [String] { get }
    var goNextStepWithForm: Observable<NewHoorayForm> { get }
}


// MARK: - EnterHoorayTagViewModelImple

public final class EnterHoorayTagViewModelImple: EnterHoorayTagViewModel {
    
    private let form: NewHoorayForm
    private let router: EnterHoorayTagRouting
    
    public init(form: NewHoorayForm,
                router: EnterHoorayTagRouting) {
        
        self.form = form
        self.router = router
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    fileprivate final class Subjects {
        @AutoCompletable var continueNext = PublishSubject<NewHoorayForm>()
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - EnterHoorayTagViewModelImple Interactor

extension EnterHoorayTagViewModelImple {
    
    public func close() {
        self.router.closeScene(animated: true, completed: nil)
    }
    
    public func goNextInputStage(with tags: [String]) {
        self.form.tags = tags
        self.subjects.continueNext.onNext(self.form)
    }
}


// MARK: - EnterHoorayTagViewModelImple Presenter

extension EnterHoorayTagViewModelImple {
    
    public var previousInputTags: [String] {
        return self.form.tags
    }
    
    public var goNextStepWithForm: Observable<NewHoorayForm> {
        return self.subjects.continueNext.asObservable()
    }
}
