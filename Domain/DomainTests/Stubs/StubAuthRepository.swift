//
//  StubAuthRepository.swift
//  DomainTests
//
//  Created by ParkHyunsoo on 2021/04/30.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import UnitTestHelpKit

@testable import Domain


class StubAuthRepository: AuthRepository, Stubbable {
    
    func fetchLastSignInAccountInfo() -> Maybe<(Auth, Member?)> {
        return self.resolve(key: "fetchLastSignInAccountInfo") ?? .empty()
    }
    
    func requestSignIn(using secret: EmailBaseSecret) -> Maybe<SigninResult> {
        self.resolve(key: "requestSignIn:secret") ?? .empty()
    }
    
    func requestSignIn(using credential: OAuthCredential) -> Maybe<SigninResult> {
        self.resolve(key: "requestSignIn:credential") ?? .empty()
    }
}
