//
//  MockOAuthService.swift
//  DomainTests
//
//  Created by ParkHyunsoo on 2021/04/30.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import UnitTestHelpKit

@testable import Domain


struct DummyOAuthType: OAuthServiceProviderType {
    let uniqueIdentifier: String = "DummyOAuthType"
}

class MockOAuthService: OAuthService, OAuthServiceProviderTypeRepresentable, Mocking {
    
    var providerType: OAuthServiceProviderType {
        return DummyOAuthType()
    }
    
    func requestSignIn() -> Maybe<OAuthCredential> {
        return self.resolve(key: "requestSignIn") ?? .empty()
    }
}

