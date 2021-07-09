//
//  LocalStorageTests+Place.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/07/09.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit

@testable import DataStore


class LocalStorageTests_Place: BaseLocalStorageTests { }

extension LocalStorageTests_Place {
    
    private var dummyPlaceForm: NewPlaceForm {
        return NewPlaceFormBuilder(base: .init(reporterID: "myID", infoProvider: .userDefine))
            .title("title")
            .thumbnail(.path("path"))
            .searchID("sid")
            .detailLink("https://www.dummy_detail.com")
            .coordinate(.init(latt: 100, long: 200))
            .address("address")
            .contact("contact")
            .categoryTags([
                            PlaceCategoryTag(placeCat: "t1", emoji: "😍"),
                            PlaceCategoryTag(placeCat: "t2", emoji: "🍿")
            ])
            .build()!
    }
    
    func testLocalStorage_saveAndLoadPendingNewPlaceForm() {
        // given
        let expect = expectation(description: "보류중인 새로룬 장소 폼 로드")
        
        // when
        let save = self.local.savePendingRegister(newPlace: self.dummyPlaceForm)
        let load = self.local.fetchRegisterPendingNewPlaceForm("myID")
        let saveAndLoad = save.flatMap{ _ in load }
        let form = self.waitFirstElement(expect, for: saveAndLoad.asObservable())?.form
        
        // then
        XCTAssertEqual(form?.title, "title")
        XCTAssertEqual(form?.thumbnail, .path("path"))
        XCTAssertEqual(form?.searchID, "sid")
        XCTAssertEqual(form?.detailLink, "https://www.dummy_detail.com")
        XCTAssertEqual(form?.coordinate.latt, 100)
        XCTAssertEqual(form?.coordinate.long, 200)
        XCTAssertEqual(form?.address, "address")
        XCTAssertEqual(form?.contact, "contact")
        XCTAssertEqual(form?.categoryTags.first?.keyword, "t1")
        XCTAssertEqual(form?.categoryTags.last?.keyword, "t2")
    }
}
