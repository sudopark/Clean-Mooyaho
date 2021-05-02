//
//  StubSocialAuthRepository.swift
//  DomainTests
//
//  Created by ParkHyunsoo on 2021/04/30.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import UnitTestHelpKit

@testable import Domain


class StubOAuth2Repository: OAuthRepository, Stubbable {
    
    func requestSignIn() -> Maybe<OAuthCredential> {
        return self.resolve(key: "requestSignIn") ?? .empty()
    }
}

