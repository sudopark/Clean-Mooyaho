//
//  MockAuthRepository.swift
//  DomainTests
//
//  Created by ParkHyunsoo on 2021/04/30.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import UnitTestHelpKit

@testable import Domain


class MockAuthRepository: AuthRepository, Mocking {
    
    func fetchLastSignInAccountInfo() -> Maybe<(Auth, Member?)> {
        return self.resolve(key: "fetchLastSignInAccountInfo") ?? .empty()
    }
    
    func signInAnonymouslyForPrepareDataAcessPermission() -> Maybe<Auth> {
        return self.resolve(key: "signInAnonymouslyForPrepareDataAcessPermission") ?? .empty()
    }
    
    func requestSignIn(using secret: EmailBaseSecret) -> Maybe<SigninResult> {
        self.resolve(key: "requestSignIn:secret") ?? .empty()
    }
    
    func requestSignIn(using credential: OAuthCredential) -> Maybe<SigninResult> {
        self.resolve(key: "requestSignIn:credential") ?? .empty()
    }
    
    func requestSignout() -> Maybe<Void> {
        return self.resolve(key: "requestSignout") ?? .empty()
    }
    
    func requestWithdrawal() -> Maybe<Void> {
        return self.resolve(key: "requestWithdrawal") ?? .empty()
    }
    
    func requestRecoverAccount() -> Maybe<Member> {
        return self.resolve(key: "requestRecoverAccount") ?? .empty()
    }
}
