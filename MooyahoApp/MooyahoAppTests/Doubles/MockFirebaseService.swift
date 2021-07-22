//
//  MockFirebaseService.swift
//  MooyahoAppTests
//
//  Created by ParkHyunsoo on 2021/05/01.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import UnitTestHelpKit
import FirebaseService

@testable import MooyahoApp


class MockFirebaseService: FirebaseService, Mocking {
    
    func setupService() {
        self.verify(key: "setupService")
    }
}
