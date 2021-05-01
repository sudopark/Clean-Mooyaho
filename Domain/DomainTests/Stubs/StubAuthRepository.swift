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
    
    func fetchLastSignInMember() -> Maybe<Member?> {
        return self.resolve(key: "fetchLastSignInMember") ?? .empty()
    }
    
    func signIn(using credential: Credential) -> Maybe<Member> {
        return self.resolve(key: "signIn:using") ?? .empty()
    }
}
