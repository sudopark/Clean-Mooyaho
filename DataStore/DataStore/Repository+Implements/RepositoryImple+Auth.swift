//
//  AuthRepositoryImple.swift
//  DataStore
//
//  Created by ParkHyunsoo on 2021/05/01.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


public protocol AuthRepositoryDefImpleDependency: AnyObject {
    
    var disposeBag: DisposeBag { get }
    var authRemote: AuthRemote { get }
    var authLocal: AuthLocalStorage & DataModelStorageSwitchable { get }
}


extension AuthRepository where Self: AuthRepositoryDefImpleDependency {

    public func fetchLastSignInAccountInfo() -> Maybe<(Auth, Member?)> {
        
        let getLastAuth = self.authLocal.fetchCurrentAuth()
        let prepareAnonymousAuthIfNeed: (Auth?) -> Maybe<Auth> = { [weak self] auth in
            logger.print(level: .debug, "last signin userID -> \(auth?.userID ?? "")")
            guard let self = self else { return .empty() }
            switch auth {
            case let .some(existing): return .just(existing)
            case .none: return self.signInAnonymouslyForPrepareDataAcessPermission()
            }
        }
        
        let prepareStorage: (Auth) -> Maybe<Auth> = { [weak self] auth in
            guard let self = self else { return .empty() }
            return self.authLocal.openStorage(for: auth)
                .map { auth }
        }
        
        let thenLoadExistingCurrentMember: (Auth) -> Maybe<(Auth, Member?)>
        thenLoadExistingCurrentMember = { [weak self] auth in
            guard let self = self else { return .empty() }
            return self.authLocal.fetchCurrentMember()
                .catchAndReturn(nil)
                .map{ (auth, $0) }
        }
        
        let switchStorageIfNeed: ((Auth, Member?)) -> Maybe<(Auth, Member?)> = { [weak self] pair in
            guard let self = self else { return .empty() }
            let isSignedInBeforeButNoMember = pair.1 == nil
            guard isSignedInBeforeButNoMember else { return .just(pair) }
            logger.print(level: .warning, "is Signed in before But No Member!! => switch to anonymousStorage")
            return self.authLocal.switchToAnonymousStorage()
                .map { pair }
        }
        
        return getLastAuth
            .flatMap(prepareAnonymousAuthIfNeed)
            .flatMap(prepareStorage)
            .flatMap(thenLoadExistingCurrentMember)
            .flatMap(switchStorageIfNeed)
    }
    
    public func signInAnonymouslyForPrepareDataAcessPermission() -> Maybe<Auth> {
        
        let updateAuthOnStorage: (Auth) -> Void = { [weak self] auth in
            guard let self = self else { return }
            self.authLocal.saveSignedIn(auth: auth)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        return self.authRemote.requestSignInAnonymously()
            .do(onNext: updateAuthOnStorage)
    }
    
    public func requestSignIn(using secret: EmailBaseSecret) -> Maybe<SigninResult> {
        let signing = self.authRemote.requestSignIn(withEmail: secret.email, password: secret.password)
        return self.requestSignInAndSaveMemberInfo(signing)
    }
    
    public func requestSignIn(using credential: OAuthCredential) -> Maybe<SigninResult> {
        
        let signing = self.authRemote.requestSignIn(using: credential)
        return self.requestSignInAndSaveMemberInfo(signing)
    }
    
    private func requestSignInAndSaveMemberInfo(_ signingAction: Maybe<SigninResult>) -> Maybe<SigninResult> {
        
        let switchStorage: (SigninResult) -> Maybe<SigninResult> = { [weak self] result in
            guard let self = self else { return .empty() }
            return self.authLocal.switchToUserStorage(result.auth.userID)
                .map { result }
        }
        
        let andSaveMemberInfo: (SigninResult) -> Void = { [weak self] result in
            guard let self = self else { return }
            self.disposeBag.insert {
                self.authLocal.saveSignedIn(auth: result.auth).subscribe()
                self.authLocal.saveSignedIn(member: result.member).subscribe()
            }
        }
        return signingAction
            .flatMap(switchStorage)
            .do(onNext: andSaveMemberInfo)
            .map{ $0 }
    }
    
    public func requestSignout() -> Maybe<Void> {
        let thenSwitchStorage: () -> Maybe<Void> = { [weak self] in
            return self?.authLocal.switchToAnonymousStorage() ?? .empty()
        }
        return self.authRemote.requestSignout()
            .flatMap(thenSwitchStorage)
    }
    
    public func requestWithdrawal() -> Maybe<Void> {
        
        let withdrawal = self.authRemote.requestWithdrawal()
        let thenSignout: () -> Maybe<Void> = { [weak self] in
            return self?.requestSignout() ?? .empty()
        }
        return withdrawal
            .flatMap(thenSignout)
    }
}
