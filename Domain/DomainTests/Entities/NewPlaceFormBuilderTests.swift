//
//  NewPlaceFormBuilderTests.swift
//  DomainTests
//
//  Created by ParkHyunsoo on 2021/05/04.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import UnitTestHelpKit

@testable import Domain


class NewPlaceFormBuilderTests: BaseTestCase {

    var builder: NewPlaceFormBuilder!
    
    override func setUp() {
        super.setUp()
        self.builder = .init(base: .init(reporterID: "reporterID", infoProvider: .userDefine))
    }
    
    override func tearDown() {
        self.builder = nil
        super.tearDown()
    }
}


extension NewPlaceFormBuilderTests {
    
    private func fullFilledBuilder() -> NewPlaceFormBuilder {
        return self.builder
            .title("title")
            .thumbnail(ImageSource(path: "path", size: .init(100, 100)))
            .searchID("searchID")
            .detailLink("detail")
            .coordinate(.init(latt: 10, long: 10))
            .address("addr")
            .categoryTags([.init(placeCat: "k1", emoji: "☠️")])
    }
    
    // 입력한 모든값 검증
    func testBuilder_buildNewPlaceFormWithInputedValues() {
        // given
        // when
        let form = fullFilledBuilder().build()
        
        // then
        XCTAssertEqual(form?.reporterID, "reporterID")
        XCTAssertEqual(form?.infoProvider, .userDefine)
        XCTAssertEqual(form?.title, "title")
        XCTAssertEqual(form?.thumbnail, ImageSource(path: "path", size: .init(100, 100)))
        XCTAssertEqual(form?.searchID, "searchID")
        XCTAssertEqual(form?.detailLink, "detail")
        XCTAssertEqual(form?.coordinate, .init(latt: 10, long: 10))
        XCTAssertEqual(form?.address, "addr")
        XCTAssertEqual(form?.categoryTags, [.init(placeCat: "k1", emoji: "☠️")])
        
    }
    
    func testBuilder_whenTitleInfoInvalid_buildFail() {
        // given
        let builder = self.fullFilledBuilder()
        
        // when + Assert
        var newBuilder = builder
        XCTAssertNotNil(newBuilder.build())
        
        newBuilder = newBuilder.title("")
        XCTAssertNil(newBuilder.build())
    }
    
    func testBuilder_whenCoordinateInfoInvalid_buildFail() {
        // given
        let builder = self.fullFilledBuilder()
        
        // when + Assert
        var newBuilder = builder
        XCTAssertNotNil(newBuilder.build())
        
        newBuilder = builder.coordinate(nil)
        XCTAssertNil(newBuilder.build())
    }
    
    func testBuilder_whenAddressInfoInvalid_buildFail() {
        // given
        let builder = self.fullFilledBuilder()
        
        // when + Assert
        var newBuilder = builder
        XCTAssertNotNil(newBuilder.build())
        
        newBuilder = builder.address("")
        XCTAssertNil(newBuilder.build())
    }
    
    func testBuilder_whenCategoryTagInfoEmpty_buildSuccess() {
        // given
        let builder = self.fullFilledBuilder()
        
        // when + Assert
        var newBuilder = builder
        XCTAssertNotNil(newBuilder.build())
        
        
        newBuilder = builder.categoryTags([])
        XCTAssertNotNil(newBuilder.build())
    }
}
