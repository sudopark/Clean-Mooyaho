//
//  FeedbackViewModel.swift
//  SettingScene
//
//  Created sudo.park on 2021/12/15.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - FeedbackViewModel

public protocol FeedbackViewModel: AnyObject, Sendable {

    // interactor
    func enterMessage(_ message: String)
    func enterContact(_ contact: String)
    func register()
    func close()
    
    // presenter
    var isConfirmable: Observable<Bool> { get }
    var isRegistering: Observable<Bool> { get }
}


// MARK: - FeedbackViewModelImple

public final class FeedbackViewModelImple: FeedbackViewModel, @unchecked Sendable {
    
    private let feedbackUsecase: FeedbackUsecase
    private let router: FeedbackRouting
    private weak var listener: FeedbackSceneListenable?
    
    public init(feedbackUsecase: FeedbackUsecase,
                router: FeedbackRouting,
                listener: FeedbackSceneListenable?) {
        
        self.feedbackUsecase = feedbackUsecase
        self.router = router
        self.listener = listener
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects: Sendable {
        let message = BehaviorRelay<String>(value: "")
        let emailAddress = BehaviorRelay<String>(value: "")
        let isRegistering = BehaviorRelay<Bool>(value: false)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - FeedbackViewModelImple Interactor

extension FeedbackViewModelImple {
    
    public func enterMessage(_ message: String) {
        self.subjects.message.accept(message)
    }
    
    public func enterContact(_ contact: String) {
        self.subjects.emailAddress.accept(contact)
    }
    
    public func register() {
        guard self.subjects.isRegistering.value == false else { return }
        
        let (message, email) = (self.subjects.message.value, self.subjects.emailAddress.value)
        
        let registered: () -> Void = { [weak self] in
            self?.subjects.isRegistering.accept(false)
            self?.router.closeScene(animated: true, completed: nil)
        }
        let handleError: (Error) -> Void = { [weak self] error in
            self?.subjects.isRegistering.accept(false)
            self?.router.alertError(error)
        }
        self.subjects.isRegistering.accept(true)
        self.feedbackUsecase
            .leaveFeedback(contract: email, message: message)
            .subscribe(onSuccess: registered,
                       onError: handleError)
            .disposed(by: self.disposeBag)
    }
    
    public func close() {
        self.router.closeScene(animated: true, completed: nil)
    }
}


// MARK: - FeedbackViewModelImple Presenter

extension FeedbackViewModelImple {
    
    public var isConfirmable: Observable<Bool> {
        
        let validateInput: (String, String) -> Bool = { message, email in
            return message.isNotEmpty && email.isEmailAddress
        }
        return Observable.combineLatest(
            self.subjects.message,
            self.subjects.emailAddress,
            resultSelector: validateInput
        )
        .distinctUntilChanged()
    }
    
    public var isRegistering: Observable<Bool> {
        return self.subjects.isRegistering
            .distinctUntilChanged()
    }
}
