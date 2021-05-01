//
//  StubLocal.swift
//  DataStoreTests
//
//  Created by ParkHyunsoo on 2021/05/02.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import UnitTestHelpKit
import Domain

@testable import DataStore


class StubLocal: Local, Stubbable {
    
    func saveSignedIn(member: Member) -> Maybe<Void> {
        self.verify(key: "saveSignedIn:member", with: member)
        return self.resolve(key: "saveSignedIn:member") ?? .empty()
    }
}
