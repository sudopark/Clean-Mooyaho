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


public enum ApplicationStatus {
    case idle
    case launched
    case forground
    case background
    case terminate
}

public protocol ApplicationUsecase {
    
    func updateApplicationActiveStatus(_ newStatus: ApplicationStatus)
    
    func loadLastSignInAccountInfo() -> Maybe<(auth: Auth, member: Member?)>
}

// MARK: - ApplicationUsecaseImple

public final class ApplicationUsecaseImple: ApplicationUsecase {
    
    private let authUsecase: AuthUsecase
    private let memberUsecase: MemberUsecase
    private let locationUsecase: UserLocationUsecase
    
    public init(authUsecase: AuthUsecase,
                memberUsecase: MemberUsecase,
                locationUsecase: UserLocationUsecase) {
        self.authUsecase = authUsecase
        self.memberUsecase = memberUsecase
        self.locationUsecase = locationUsecase
        
        self.bindApplicationStatus()
    }
    
    fileprivate struct Subjects {
        let applicationStatus = BehaviorRelay<ApplicationStatus>(value: .idle)
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
        
        let didLanched = status.filter{ $0 == .launched }.take(1).map{ _ in }
        let enterForeground = status.filter{ $0 == .forground }.map{ _ in true }
        let enterBackground = status.filter{ $0 == .background }.map{ _ in false }
        let terminated = status.filter{ $0 == .terminate }.map{ _ in false }
        
        let isUserInUseApp = Observable
            .merge(didLanched.map{ true }, enterForeground, enterBackground, terminated)
            .distinctUntilChanged()
        
        isUserInUseApp
            .flatMapLatest{ [weak self] inUse in self?.waitForLocationUploadableAuth(inUse) ?? .empty()  }
            .subscribe(onNext: { [weak self] auth in
                if let userID = auth?.userID {
                    self?.locationUsecase.startUploadUserLocation(for: userID)
                } else {
                    self?.locationUsecase.stopUplocationUserLocation()
                }
            })
            .disposed(by: self.disposeBag)
        
        let preparedAuth = self.authUsecase.currentAuth.compactMap{ $0 }.distinctUntilChanged()
        Observable.combineLatest(preparedAuth, isUserInUseApp)
            .subscribe(onNext: { [weak self] auth, isUse in
                self?.memberUsecase.updateUserIsOnline(auth.userID, isOnline: isUse)
            })
            .disposed(by: self.disposeBag)
        
        didLanched
            .subscribe(onNext: { [weak self] in
                self?.setupUserAuth()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func setupUserAuth() {
        
        self.authUsecase.loadLastSignInAccountInfo()
            .subscribe()
            .disposed(by: self.disposeBag)
    }
    
    private func waitForLocationUploadableAuth(_ isUserInUseApp: Bool) -> Observable<Auth?> {
        guard isUserInUseApp else { return .just(nil) }
        let preparedAuth = self.authUsecase.currentAuth.compactMap{ $0 }.distinctUntilChanged()
        let permissionGranted = self.locationUsecase.checkHasPermission().asObservable()
            .flatMap { [weak self] status -> Observable<Void> in
                guard let self = self else { return .empty() }
                guard status != .granted else { return .just(()) }
                return self.locationUsecase.isAuthorized.filter{ $0 }.map{ _ in }
            }
        return Observable
            .combineLatest(preparedAuth, permissionGranted)
            .map{ $0.0 }
    }
}


// MARK: - output

extension ApplicationUsecaseImple {
    
    public func loadLastSignInAccountInfo() -> Maybe<(auth: Auth, member: Member?)> {
        return self.authUsecase.loadLastSignInAccountInfo()
    }
}
