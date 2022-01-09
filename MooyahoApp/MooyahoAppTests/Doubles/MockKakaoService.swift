//
//  MockKakaoService.swift
//  MooyahoAppTests
//
//  Created by ParkHyunsoo on 2021/05/01.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain
import UnitTestHelpKit

@testable import Readmind


class MockKakaoService: KakaoService, Mocking {
    
    let providerType: OAuthServiceProviderType = OAuthServiceProviderTypes.kakao
    
    func setupService() {
        self.verify(key: "setupService")
    }
    
    func canHandleURL(_ url: URL) -> Bool {
        return self.resolve(key: "canHandleURL") ?? false
    }
    
    func handle(url: URL) -> Bool {
        return self.resolve(key: "handle:url") ?? false
    }
    
    func requestSignIn() -> Maybe<OAuthCredential> {
        return self.resolve(key: "requestSignIn") ?? .empty()
    }
}

