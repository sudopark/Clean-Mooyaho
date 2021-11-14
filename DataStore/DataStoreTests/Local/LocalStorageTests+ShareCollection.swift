//
//  LocalStorageTests+ShareCollection.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/11/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import UnitTestHelpKit

import DataStore


class LocalStorageTests_ShareCollection: BaseLocalStorageTests {

    
    private func dummyCollection(for int: Int) -> SharedReadCollection {
        return .init(uid: "id:\(int)", name: "name:\(int)", createdAt: .now(), lastUpdated: .now())
            |> \.description .~ "desc"
            |> \.categoryIDs .~ ["c1"]
            |> \.ownerID .~ "some"
    }
}


extension LocalStorageTests_ShareCollection {
    
    func testStorage_updateCollections_andLoadLastOpenTimeDescending() {
        // given
        let expect = expectation(description: "복수의 콜렉션 저장하고 마지막 오픈시간 내림차순으로 로드")
        let collection1 = self.dummyCollection(for: 1) |> \.userLastOpenTime .~ 10
        let collection2 = self.dummyCollection(for: 2) |> \.userLastOpenTime .~ nil
        let collection3 = self.dummyCollection(for: 3) |> \.userLastOpenTime .~ 1000
        
        // when
        let updating = self.local.updateLastSharedCollections([collection1, collection2, collection3])
        let load = self.local.fetchLatestSharedCollections()
        let updateAndLoad = updating.flatMap { load }
        let collections = self.waitFirstElement(expect, for: updateAndLoad.asObservable())
        
        // then
        let collectionIDs = collections?.map { $0.uid }
        XCTAssertEqual(collectionIDs, ["id:3", "id:1", "id:2"])
    }
}
