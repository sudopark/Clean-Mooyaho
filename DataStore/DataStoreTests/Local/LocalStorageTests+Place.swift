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
    
    func testLocalStorage_deletePendingNewPlaceForm() {
        // given
        let expect = expectation(description: "저장된 보류중인 새로운 장소 삭제")
        
        // when
        let save = self.local.savePendingRegister(newPlace: self.dummyPlaceForm)
        let load = self.local.fetchRegisterPendingNewPlaceForm("myID").filter{ $0 != nil }
        let remove = self.local.removePendingRegisterForm("myID")
        let loadAfter = self.local.fetchRegisterPendingNewPlaceForm("myID")
        let action = save.flatMap{ _ in load }.flatMap{ _ in remove }.flatMap{ _ in loadAfter }
        let form = self.waitFirstElement(expect, for: action.asObservable())
        
        // then
        XCTAssertNil(form)
    }
}


extension LocalStorageTests_Place {
    
    private var dummyPlace: Place {
        
        let tags = [
            PlaceCategoryTag(placeCat: "t1", emoji: "😍"),
            PlaceCategoryTag(placeCat: "t2", emoji: "🍿")
        ]
        
        return Place(uid: "pid", title: "title",
                     thumbnail: .path("path value"), externalSearchID: "ext_id",
                     detailLink: "detailLink", coordinate: .init(latt: 100, long: 100),
                     address: "address", contact: "contact",
                     categoryTags: tags,
                     reporterID: "rid", infoProvider: .userDefine,
                     createdAt: 100, pickCount: 2, lastPickedAt: 130)
    }
    
    func testLocalStorage_savePlaceAndLoad() {
        // given
        let expect = expectation(description: "place 저장하고 로드")
        let dummyPlace = self.dummyPlace
        
        // when
        let save = self.local.savePlace(dummyPlace)
        let load = self.local.fetchPlace("pid")
        let saveAndload = save.flatMap{ _ in load }
        let place = self.waitFirstElement(expect, for: saveAndload.asObservable())
        
        // then
        XCTAssertEqual(place?.uid, dummyPlace.uid)
        XCTAssertEqual(place?.title, dummyPlace.title)
        XCTAssertEqual(place?.thumbnail, dummyPlace.thumbnail)
        XCTAssertEqual(place?.coordinate, dummyPlace.coordinate)
        XCTAssertEqual(place?.address, dummyPlace.address)
        XCTAssertEqual(place?.contact, dummyPlace.contact)
        XCTAssertEqual(place?.placeCategoryTags.count, dummyPlace.placeCategoryTags.count)
        XCTAssertEqual(place?.reporterID, dummyPlace.reporterID)
        XCTAssertEqual(place?.requireInfoProvider, dummyPlace.requireInfoProvider)
        XCTAssertEqual(place?.createdAt, dummyPlace.createdAt)
        XCTAssertEqual(place?.placePickCount, dummyPlace.placePickCount)
        XCTAssertEqual(place?.lastPickedAt, dummyPlace.lastPickedAt)
    }
    
    func testLocalStorage_saveNoThumbnailPlaceAndLoad() {
        // given
        let expect = expectation(description: "thumbnail 없는 place 저장하고 로드")
        var dummyPlace = self.dummyPlace
        dummyPlace.thumbnail = nil
        
        // when
        let save = self.local.savePlace(dummyPlace)
        let load = self.local.fetchPlace("pid")
        let saveAndload = save.flatMap{ _ in load }
        let place = self.waitFirstElement(expect, for: saveAndload.asObservable())
        
        // then
        XCTAssertNotNil(place)
        XCTAssertNil(place?.thumbnail)
    }
}
