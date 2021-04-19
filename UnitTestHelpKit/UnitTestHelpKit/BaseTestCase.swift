//
//  BaseTestCase.swift
//  UnitTestHelpKit
//
//  Created by ParkHyunsoo on 2021/04/19.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

open class BaseTestCase: XCTestCase {
    
    public var timeout: TimeInterval = 10
    public var timeout_long: TimeInterval = 100
    public var timeout_veryLong: TimeInterval = 500
}
