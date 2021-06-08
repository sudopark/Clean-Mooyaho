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
    func skipInput()
    func goNextInputStage(with tags: [String])
    
    // presenter
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
        let continueNext = PublishSubject<NewHoorayForm>()
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - EnterHoorayTagViewModelImple Interactor

extension EnterHoorayTagViewModelImple {
    
    public func skipInput() {
        self.router.closeScene(animated: true) { [weak self] in
            guard let self = self else { return }
            self.subjects.continueNext.onNext(self.form)
        }
    }
    
    public func goNextInputStage(with tags: [String]) {
        self.router.closeScene(animated: true) { [weak self] in
            guard let self = self else { return }
            self.form.tags = tags
            self.subjects.continueNext.onNext(self.form)
        }
    }
}


// MARK: - EnterHoorayTagViewModelImple Presenter

extension EnterHoorayTagViewModelImple {
    
    public var goNextStepWithForm: Observable<NewHoorayForm> {
        return self.subjects.continueNext.asObservable()
    }
}
