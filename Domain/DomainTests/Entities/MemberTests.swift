//
//  MemberTests.swift
//  DomainTests
//
//  Created by sudo.park on 2021/06/01.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import UnitTestHelpKit

@testable import Domain


class MemberTests: BaseTestCase {
    
    func test_memberProfileNotSetup() {
        // given
        var member = Member(uid: "uid")
        // when + then
        XCTAssertEqual(member.isProfileSetup, false)
        
        member.introduction = "intro"
        XCTAssertEqual(member.isProfileSetup, false)
        
        member.icon = .emoji("⛹️")
        XCTAssertEqual(member.isProfileSetup, false)
        
        member.nickName = "nick"
        XCTAssertEqual(member.isProfileSetup, true)
    }
}
