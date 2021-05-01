//
//  StubFirebaseService.swift
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


class StubFirebaseService: FirebaseService, Stubbable {
    
    func setupService() {
        self.verify(key: "setupService")
    }
}
