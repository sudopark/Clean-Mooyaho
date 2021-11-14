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
        return .init(shareID: "s:\(int)", uid: "id:\(int)", name: "name:\(int)",
                     createdAt: .now(), lastUpdated: .now())
            |> \.description .~ "desc"
            |> \.categoryIDs .~ ["c1"]
            |> \.ownerID .~ "some"
    }
}


extension LocalStorageTests_ShareCollection {
    
    func testStorage_updateCollections_andLoadLastOpenTimeDescending() {
        // given
        let expect = expectation(description: "복수의 콜렉션 저장하고 마지막 오픈시간 내림차순으로 로드")
        let collection1 = self.dummyCollection(for: 1)
        let collection2 = self.dummyCollection(for: 2)
        let collection3 = self.dummyCollection(for: 3)
        
        // when
        let updating = self.local.replaceLastSharedCollections([collection1, collection2, collection3])
        let load = self.local.fetchLatestSharedCollections()
        let updateAndLoad = updating.flatMap { load }
        let collections = self.waitFirstElement(expect, for: updateAndLoad.asObservable())
        
        // then
        let collectionIDs = collections?.map { $0.uid }
        XCTAssertEqual(collectionIDs, ["id:3", "id:2", "id:1"])
    }
    
    func testStorage_whenUpdateCollection_becomeLatestCollection() {
        // given
        let expect = expectation(description: "단일 아이템 업데이트시에 가장 최근 업데이트된 목록으로 업데이트됨")
        let collections = (0..<3).map { self.dummyCollection(for: $0) }
        
        // when
        let setup = self.local.replaceLastSharedCollections(collections)
        let update = self.local.saveSharedCollection(self.dummyCollection(for: 1))
        let load = self.local.fetchLatestSharedCollections()
        let setupUpdateAndLoad = setup.flatMap { update }.flatMap { load }
        let updatedCollections = self.waitFirstElement(expect, for: setupUpdateAndLoad.asObservable())
        
        // then
        let collectionIDs = updatedCollections?.map { $0.uid }
        XCTAssertEqual(collectionIDs, ["id:1", "id:2", "id:0"])
    }
}
