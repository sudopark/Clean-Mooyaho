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
    private let shareUsecase: ShareReadCollectionUsecase
    
    public init(authUsecase: AuthUsecase,
                memberUsecase: MemberUsecase,
                shareUsecase: ShareReadCollectionUsecase) {
        self.authUsecase = authUsecase
        self.memberUsecase = memberUsecase
        self.shareUsecase = shareUsecase
        
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
        
        let status = self.subjects.applicationStatus.distinctUntilChanged()
//
        let didLanched = status.filter{ $0 == .launched }.take(1).map{ _ in }
        let enterForeground = status.filter{ $0 == .forground }.map{ _ in true }
        let enterBackground = status.filter{ $0 == .background }.map{ _ in false }
        let terminated = status.filter{ $0 == .terminate }.map{ _ in false }
//
        let isUserInUseApp = Observable
            .merge(didLanched.map{ true }, enterForeground, enterBackground, terminated)
            .distinctUntilChanged()
        
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
        let signInMemberID = self.memberUsecase.currentMember.map { $0?.uid }.distinctUntilChanged()
        Observable.combineLatest(signInMemberID, isUserInUseApp)
            .subscribe(onNext: { [weak self] memberID, isUse in
                guard let memberID = memberID, isUse == true else { return }
                self?.refreshSignInMemberBaseDatas(for: memberID)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func refreshSignInMemberBaseDatas(for memberID: String) {
        self.memberUsecase.refreshMembers([memberID])
        self.shareUsecase.refreshMySharingColletionIDs()
        // TODO: 검색 가능한 단어 전부다 추출
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
