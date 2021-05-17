//
//  NewHoorayFormBuilderTests.swift
//  DomainTests
//
//  Created by sudo.park on 2021/05/19.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import UnitTestHelpKit

@testable import Domain


class NewHoorayFormBuilderTests: BaseTestCase {

    var builder: NewHoorayFormBuilder!
    
    override func setUp() {
        super.setUp()
        self.builder = .init(base: .init(publisherID: "some"))
    }
    
    override func tearDown() {
        self.builder = nil
        super.tearDown()
    }
}

extension NewHoorayFormBuilderTests {
    
    // 입력한 모든값 검증
    func testBuilder_buildNewPlaceFormWithInputedValues() {
        // given
        let builder = self.builder
            .placeID("placeID")
            .location(Coordinate(latt: 0, long: 0))
            .timeStamp(1)
            .spreadDistance(10)
            .aliveDuration(100)
        
        // when
        let form = builder.build()
        
        // then
        XCTAssertNotNil(form)
    }
}
