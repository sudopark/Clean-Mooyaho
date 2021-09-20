//
//  LocalStorageTests+ReadItemOptions.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/09/20.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import UnitTestHelpKit

import DataStore


class LocalStorageTests_ReadItemOptions: BaseLocalStorageTests {
    
    func testStorage_updateAndFetchIsShrinkMode() {
        // given
        let expect = expectation(description: "shrink 모드 저장 및 로드")
        
        // when
        let update = self.local.updateReadItemIsShrinkMode(true)
        let loading = self.local.fetchReadItemIsShrinkMode()
        let updateAndLoad = update.flatMap{ loading }
        let isOn = self.waitFirstElement(expect, for: updateAndLoad.asObservable())
        
        
        // then
        XCTAssertEqual(isOn, true)
    }
    
    func testStorage_updateAndFetchSortOrder() {
        // given
        let expect = expectation(description: "sort order 저장 및 로드")
        let update = self.local.updateReadItemSortOrder(for: "some", to: .byCustomOrder)
        let updateOther = self.local.updateReadItemSortOrder(for: "other", to: .byPriority(false))
        let loading = self.local.fetchReadItemSortOrder(for: "some")
        let updateAndLoad = update.flatMap{ updateOther }.flatMap{ loading }
        let order = self.waitFirstElement(expect, for: updateAndLoad.asObservable())
        
        
        // then
        XCTAssertEqual(order, .byCustomOrder)
    }
    
    func testStorage_updateAndFetchCustomSortOrder() {
        // given
        let expect = expectation(description: "custom sort order 저장 및 로드")
        let update = self.local.updateReadItemCustomOrder(for: "some", itemIDs: ["1", "2"])
        let loading = self.local.fetchReadItemCustomOrder(for: "some")
        let updateAndLoad = update.flatMap{ loading }
        let order = self.waitFirstElement(expect, for: updateAndLoad.asObservable())
        
        
        // then
        XCTAssertEqual(order, ["1", "2"])
    }
}