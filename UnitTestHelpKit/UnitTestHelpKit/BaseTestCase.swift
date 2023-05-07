//
//  BaseTestCase.swift
//  UnitTestHelpKit
//
//  Created by ParkHyunsoo on 2021/04/19.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

open class BaseTestCase: XCTestCase, @unchecked Sendable {
    
    public var timeout: TimeInterval = 10 * 0.001
    public var timeout_long: TimeInterval = 100 * 0.001
    public var timeout_veryLong: TimeInterval = 500 * 0.001
}
