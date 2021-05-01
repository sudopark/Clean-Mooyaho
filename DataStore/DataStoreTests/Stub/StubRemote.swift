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
    
    func requestSignIn(using credential: Credential) -> Maybe<Member> {
        return self.resolve(key: "requestSignIn") ?? .empty()
    }
}
