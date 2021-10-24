//
//  LocalStorageTests_ReadLinkMemo.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/10/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import UnitTestHelpKit

import DataStore


class LocalStorageTests_ReadLinkMemo: BaseLocalStorageTests {
    
}

extension LocalStorageTests_ReadLinkMemo {
    
    func testStorage_saveAndLoadMemo() {
        // given
        let expect = expectation(description: "아이템 저장하로 로드")
        let dummy = ReadLinkMemo(itemID: "some")
        
        // when
        let save = self.local.updateMemo(dummy)
        let load = self.local.fetchMemo(for: "some")
        let saveAndLoad = save.flatMap{ load }
        let memo = self.waitFirstElement(expect, for: saveAndLoad.asObservable())
        
        // then
        XCTAssertNotNil(memo)
    }
    
    func testStorage_updateMemo() {
        // given
        let expect = expectation(description: "아이템 수정하고 로드")
        let dummy = ReadLinkMemo(itemID: "some")
        
        // when
        let save = self.local.updateMemo(dummy)
        let update = self.local.updateMemo <| (dummy |> \.content .~ "value")
        let load = self.local.fetchMemo(for: "some")
        let saveUpdateAndLoad = save.flatMap { update }.flatMap{ load }
        let memo = self.waitFirstElement(expect, for: saveUpdateAndLoad.asObservable())
        
        // then
        XCTAssertEqual(memo?.content, "value")
    }
    
    func testStorage_deleteMemo() {
        // given
        let expect = expectation(description: "아이템 삭제하고 로드")
        let dummy = ReadLinkMemo(itemID: "some")
        
        // when
        let save = self.local.updateMemo(dummy)
        let remove = self.local.deleteMemo(for: "some")
        let load = self.local.fetchMemo(for: "some")
        let saveDeleteAndLoad = save.flatMap { remove }.flatMap{ load }
        let memo = self.waitFirstElement(expect, for: saveDeleteAndLoad.asObservable())
        
        // then
        XCTAssertNil(memo)
    }
}
