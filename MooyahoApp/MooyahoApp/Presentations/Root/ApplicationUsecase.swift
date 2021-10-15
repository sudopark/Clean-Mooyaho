//
//  ApplicationUsecase.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/05/25.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


public protocol ApplicationUsecase {
    
    func updateApplicationActiveStatus(_ newStatus: ApplicationStatus)
    
    func loadLastSignInAccountInfo() -> Maybe<(auth: Auth, member: Member?)>
    
    func userFCMTokenUpdated(_ newToken: String?)
    
    var currentSignedInMemeber: Observable<Member?> { get }
}

// MARK: - ApplicationUsecaseImple

public final class ApplicationUsecaseImple: ApplicationUsecase {
    
    private let authUsecase: AuthUsecase
    private let memberUsecase: MemberUsecase
    
    public init(authUsecase: AuthUsecase,
                memberUsecase: MemberUsecase) {
        self.authUsecase = authUsecase
        self.memberUsecase = memberUsecase
        
        self.bindApplicationStatus()
        self.bindPushTokenUpload()
    }
    
    fileprivate struct Subjects {
        let applicationStatus = BehaviorRelay<ApplicationStatus>(value: .idle)
        let fcmToken = BehaviorSubject<String?>(value: nil)
    }
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - input

extension ApplicationUsecaseImple {
    
    public func updateApplicationActiveStatus(_ newStatus: ApplicationStatus) {
        self.subjects.applicationStatus.accept(newStatus)
    }
    
    private func bindApplicationStatus() {
        
//        let status = self.subjects.applicationStatus.distinctUntilChanged()
//
//        let didLanched = status.filter{ $0 == .launched }.take(1).map{ _ in }
//        let enterForeground = status.filter{ $0 == .forground }.map{ _ in true }
//        let enterBackground = status.filter{ $0 == .background }.map{ _ in false }
//        let terminated = status.filter{ $0 == .terminate }.map{ _ in false }
//
//        let isUserInUseApp = Observable
//            .merge(didLanched.map{ true }, enterForeground, enterBackground, terminated)
//            .distinctUntilChanged()
        
//        isUserInUseApp
//            .flatMapLatest{ [weak self] inUse in self?.waitForLocationUploadableAuth(inUse) ?? .empty()  }
//            .subscribe(onNext: { [weak self] auth in
//                if let userID = auth?.userID {
//                    self?.locationUsecase.startUploadUserLocation(for: userID)
//                } else {
//                    self?.locationUsecase.stopUplocationUserLocation()
//                }
//            })
//            .disposed(by: self.disposeBag)
        
//        let deviceID = AppEnvironment.deviceID
//        let preparedAuth = self.authUsecase.currentAuth.compactMap{ $0 }.distinctUntilChanged()
//        Observable.combineLatest(preparedAuth, isUserInUseApp)
//            .subscribe(onNext: { [weak self] auth, isUse in
//                self?.memberUsecase.updateUserIsOnline(auth.userID, deviceID: deviceID, isOnline: isUse)
//            })
//            .disposed(by: self.disposeBag)
    }
}

// MARK: - input: handle notification

extension ApplicationUsecaseImple {
    
    public func userFCMTokenUpdated(_ newToken: String?) {
        self.subjects.fcmToken.onNext(newToken)
    }
    
    private func bindPushTokenUpload() {
        
        let deviceID = AppEnvironment.deviceID
        let uploadToken: (String, String) -> Void = { [weak self] memberID, token in
            self?.memberUsecase.updatePushToken(memberID, deviceID: deviceID, newToken: token)
        }
        
        let currentMemberID = self.memberUsecase.currentMember.compactMap{ $0?.uid }.distinctUntilChanged()
        let fcmToken = self.subjects.fcmToken.compactMap{ $0 }.distinctUntilChanged()
        
        Observable.combineLatest(currentMemberID, fcmToken)
            .subscribe(onNext: uploadToken)
            .disposed(by: self.disposeBag)
    }
}


// MARK: - output

extension ApplicationUsecaseImple {
    
    public func loadLastSignInAccountInfo() -> Maybe<(auth: Auth, member: Member?)> {
        return self.authUsecase.loadLastSignInAccountInfo()
    }
    
    public var currentSignedInMemeber: Observable<Member?> {
        return self.memberUsecase.currentMember
    }
}
