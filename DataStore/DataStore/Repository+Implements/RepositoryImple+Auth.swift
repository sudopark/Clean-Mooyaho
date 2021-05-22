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
    var authLocal: AuthLocalStorage { get }
}


extension AuthRepository where Self: AuthRepositoryDefImpleDependency {

    public func fetchLastSignInAccountInfo() -> Maybe<(Auth, Member?)> {
        
        let getLastAuth = self.authLocal.fetchCurrentAuth()
        let prepareAnonymousAuthIfNeed: (Auth?) -> Maybe<Auth> = { [weak self] auth in
            guard let self = self else { return .empty() }
            switch auth {
            case let .some(existing): return .just(existing)
            case .none: return self.signInAnonymouslyForPrepareDataAcessPermission()
            }
        }
        
        let thenLoadExistingCurrentMember: (Auth) -> Maybe<(Auth, Member?)>
        thenLoadExistingCurrentMember = { [weak self] auth in
            guard let self = self else { return .empty() }
            return self.authLocal.fetchCurrentMember().map{ (auth, $0) }
        }
        
        return getLastAuth
            .flatMap(prepareAnonymousAuthIfNeed)
            .flatMap(thenLoadExistingCurrentMember)
    }
    
    private func signInAnonymouslyForPrepareDataAcessPermission() -> Maybe<Auth> {
        
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
        let andSaveMemberInfo: (SigninResult) -> Void = { [weak self] result in
            guard let self = self else { return }
            self.disposeBag.insert {
                self.authLocal.saveSignedIn(auth: result.auth).subscribe()
                self.authLocal.saveSignedIn(member: result.member).subscribe()
            }
        }
        return signingAction
            .do(onNext: andSaveMemberInfo)
            .map{ $0 }
    }
}
