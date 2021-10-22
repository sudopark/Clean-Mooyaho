//
//  LocalStorageTests+ReadRemind.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/10/23.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit

import DataStore


class LocalStorageTests_ReadRemind: BaseLocalStorageTests {
    
    private var dummyReadreminds: [ReadRemind] {
        return (0..<10).map { .dummy($0) }
    }
}


extension LocalStorageTests_ReadRemind {
    
    func testStorage_saveAndLoadReminds() {
        // given
        let expect = expectation(description: "저장된 리마인드 로드")
        let dummies = self.dummyReadreminds
        let savingJobs = dummies.map { self.local.updateReadRemind($0) }
        let saveAll = savingJobs.reduce(Observable<Void>.empty()) { acc, next in
            acc.concat(next)
        }
        .takeLast(1)
        let loading = self.local.fetchReadReminds(for: dummies.map { $0.itemID } + ["invalid id"])
        
        // when
        let saveAndLoad = saveAll.flatMap { loading }
        let loadedReminds = self.waitFirstElement(expect, for: saveAndLoad)
        
        // then
        XCTAssertEqual(loadedReminds?.map { $0.uid }, dummies.map { $0.uid })
    }
    
    func testStorage_updateSavedRemind() {
        // given
        let expect = expectation(description: "저장된 remind 업데이트")
        let oldRemind = self.dummyReadreminds.first!
        let newRemind = ReadRemind(uid: oldRemind.uid, itemID: oldRemind.itemID, scheduledTime: 100)
        
        // when
        let save = self.local.updateReadRemind(oldRemind)
        let update = self.local.updateReadRemind(newRemind)
        let load = self.local.fetchReadReminds(for: [oldRemind.itemID])
        let saveUpdateAndLoad = save.flatMap { update }.flatMap { load }
        let loadedRemind = self.waitFirstElement(expect, for: saveUpdateAndLoad.asObservable())
        
        // then
        XCTAssertEqual(loadedRemind?.count, 1)
        XCTAssertEqual(loadedRemind?.first?.scheduledTime, 100)
    }
    
    func testStorage_removeRemind() {
        // given
        let expect = expectation(description: "저장된 리마인드 삭제")
        let remind = self.dummyReadreminds.first!
        
        // when
        let save = self.local.updateReadRemind(remind)
        let remove = self.local.removeReadRemind(for: remind.uid)
        let load = self.local.fetchReadReminds(for: [remind.itemID])
        let saveRemoteAndLoad = save.flatMap { remove }.flatMap { load }
        let loadedRemind = self.waitFirstElement(expect, for: saveRemoteAndLoad.asObservable())
        
        // then
        XCTAssertEqual(loadedRemind?.count, 0)
    }
}
