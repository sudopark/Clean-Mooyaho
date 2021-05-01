//
//  StubRemote.swift
//  DataStoreTests
//
//  Created by ParkHyunsoo on 2021/05/02.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain
import UnitTestHelpKit

@testable import DataStore


class StubRemote: Remote, Stubbable {
    
    func requestSignInAnonymously() -> Maybe<Void> {
        self.verify(key: "requestSignInAnonymously")
        return self.resolve(key: "requestSignInAnonymously") ?? .empty()
    }
    
    func requestSignIn(withEmail email: String, password: String) -> Maybe<DataModels.Member> {
        return self.resolve(key: "requestSignIn:withEmail") ?? .empty()
    }
    
    func requestSignIn(using credential: ReqParams.OAuthCredential) -> Maybe<DataModels.Member> {
        return self.resolve(key: "requestSignIn:credential") ?? .empty()
    }
}
