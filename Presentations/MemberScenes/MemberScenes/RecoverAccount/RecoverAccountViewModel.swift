//
//  RecoverAccountViewModel.swift
//  MemberScenes
//
//  Created sudo.park on 2022/01/09.
//  Copyright © 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - RecoverAccountViewModel

public protocol RecoverAccountViewModel: AnyObject {

    // interactor
    func confirmRecover()
    
    // presenter
    var memberInfo: Observable<MemberInfo> { get }
    var deactivateDateText: Observable<String> { get }
    var isRecovering: Observable<Bool> { get }
}


// MARK: - RecoverAccountViewModelImple

public final class RecoverAccountViewModelImple: RecoverAccountViewModel {
    
    private let authUsecase: AuthUsecase
    private let memberUsecase: MemberUsecase
    private let router: RecoverAccountRouting
    private weak var listener: RecoverAccountSceneListenable?
    
    public init(authUsecase: AuthUsecase,
                memberUsecase: MemberUsecase,
                router: RecoverAccountRouting,
                listener: RecoverAccountSceneListenable?) {
        
        self.authUsecase = authUsecase
        self.memberUsecase = memberUsecase
        self.router = router
        self.listener = listener
        
        self.bindCurrentMember()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
        
        let member = BehaviorRelay<Member?>(value: nil)
        let isRecovering = BehaviorRelay<Bool>(value: false)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private func bindCurrentMember() {
        
        self.memberUsecase.currentMember
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] member in
                self?.subjects.member.accept(member)
            })
            .disposed(by: self.disposeBag)
    }
}


// MARK: - RecoverAccountViewModelImple Interactor

extension RecoverAccountViewModelImple {
    
    
    public func confirmRecover() {
        
        guard self.subjects.isRecovering.value == false else { return }
        
        let recovered: (Member) -> Void = { [weak self] newMember in
            self?.subjects.member.accept(newMember)
            self?.subjects.isRecovering.accept(false)
            self?.dissmissAndShowRecovered(newMember)
        }
        
        let handleError: (Error) -> Void = { [weak self] error in
            self?.subjects.isRecovering.accept(false)
            self?.router.alertError(error)
        }
        
        self.subjects.isRecovering.accept(true)
        
        self.authUsecase.recoverAccount()
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: recovered, onError: handleError)
            .disposed(by: self.disposeBag)
    }
    
    private func dissmissAndShowRecovered(_ newMember: Member) {
        self.router.closeScene(animated: true) { [weak self] in
            self?.listener?.recoverAccount(didCompleted: newMember)
        }
    }
}


// MARK: - RecoverAccountViewModelImple Presenter

extension RecoverAccountViewModelImple {
    
    public var memberInfo: Observable<MemberInfo> {
        return self.subjects.member
            .compactMap { $0 }
            .map { MemberInfo(member: $0) }
            .distinctUntilChanged()
    }
    
    public var deactivateDateText: Observable<String> {
        let transform: (TimeStamp?) -> String = { timeStamp in
            guard let time = timeStamp else { return "" }
            let dateText = time.dateText(formText: "yyyy.MM.dd")
            return "Withdrawal request date: %@".localized(with: dateText)
        }
        return self.subjects.member
            .map { $0?.deactivatedDateTimeStamp }
            .map(transform)
            .distinctUntilChanged()
    }
    
    public var isRecovering: Observable<Bool> {
        return self.subjects.isRecovering
            .distinctUntilChanged()
    }
}
