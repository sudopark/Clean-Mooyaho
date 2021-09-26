//
//  LocalStorageTests+ReadItem.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/09/18.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import UnitTestHelpKit

import DataStore


class LocalStorageTests_ReadItem: BaseLocalStorageTests {
    
    private var dummyCategories: [ItemCategory] {
        return (0..<3).map{ .init(name: "n:\($0)", colorCode: "$0") }
    }
    
    private func collection(at int: Int, parent: String? = nil) -> ReadCollection {
        return ReadCollection(uid: "c:\(int)", name: "collection:\(int)", createdAt: .now(), lastUpdated: .now())
            |> \.parentID .~ parent
            |> \.categories .~ self.dummyCategories
    }
    
    private func link(at int: Int, parent: String? = nil) -> ReadLink {
        return ReadLink(uid: "l:\(int)", link: "link:\(int)", createAt: .now(), lastUpdated: .now())
            |> \.parentID .~ parent
            |> \.categories .~ self.dummyCategories
    }
    
    private func dummyMyItems() -> [ReadItem] {
        
        let (c1,        c2,  l1) = (self.collection(at: 1), self.collection(at: 2), self.link(at: 1))
        let (c11, l11,  l22) = (self.collection(at: 11, parent: c1.uid), self.link(at: 11, parent: c1.uid),
                                self.link(at: 22, parent: c2.uid))
        let l111 = self.link(at: 111, parent: c11.uid)
        return [c1, c11, l111, l11, c2, l22, l1]
    }
}


extension LocalStorageTests_ReadItem {
    
    // load my item -> c1, c2, l1
    func testStorage_loadMyItems() {
        // given
        let expect = expectation(description: "내 아이템(최상위 아이템) 로드")
        let saveAllItems = self.local.updateReadItems(self.dummyMyItems())
        
        // when
        let loadMyItems = self.local.fetchMyItems()
        let saveAndLoad = saveAllItems.flatMap{ _ in loadMyItems }
        let items = self.waitFirstElement(expect, for: saveAndLoad.asObservable())
        
        // then
        let myItemIDs = items?.map{ $0.uid }
        XCTAssertEqual(myItemIDs, [
            self.collection(at: 1).uid, self.collection(at: 2).uid, self.link(at: 1).uid
        ])
    }
    
    // load c1 items -> c11, l11
    func testStorage_loadCollectionItems() {
        // given
        let expect = expectation(description: "collection의 item 로드")
        let saveAllItems = self.local.updateReadItems(self.dummyMyItems())
        
        // when
        let collection1 = self.collection(at: 1)
        let loadCollection1items = self.local.fetchCollectionItems(collection1.uid)
        let saveAndLoad = saveAllItems.flatMap{ _ in loadCollection1items }
        let items = self.waitFirstElement(expect, for: saveAndLoad.asObservable())
        
        // then
        let itemIDs = items?.map{ $0.uid }
        XCTAssertEqual(itemIDs, [
            self.collection(at: 11).uid, self.link(at: 11).uid
        ])
    }
    
    // add node c22 -> load c2 items -> c22, l22
    func testStorage_addC22AtC2_andLoadC2Items() {
        // given
        let expect = expectation(description: "c2 하위에 c22 추가하고 c2 item 로드")
        let saveAllItems = self.local.updateReadItems(self.dummyMyItems())
        
        // when
        let collection2 = self.collection(at: 2)
        let collection22 = self.collection(at: 22) |> \.parentID .~ collection2.uid
        let saveCollection22 = self.local.updateReadItems([collection22])
        let loadCollection2items = self.local.fetchCollectionItems(collection2.uid)
        let saveAndLoad = saveAllItems.flatMap{ _ in saveCollection22 }.flatMap { loadCollection2items }
        let items = self.waitFirstElement(expect, for: saveAndLoad.asObservable())
        
        // then
        let itemIDs = items?.map{ $0.uid }
        XCTAssertEqual(itemIDs, [
            self.collection(at: 22).uid, self.link(at: 22).uid
        ])
    }
    
    // save l2 at root -> load and verify fields
    func testStorage_saveNewLink_andVerifyAllFields() {
        // given
        let expect = expectation(description: "link item 저장 이후 필드 검사")
        
        let link = ReadLink(uid: "uid", link: "link://www", createAt: 100, lastUpdated: 100)
            |> \.ownerID .~ "owner"
            |> \.customName .~ "custom name"
            |> \.priority .~ .afterAWhile
            |> \.categories .~ [.init(name: "c1", colorCode: "0")]
        
        // when
        let save = self.local.updateReadItems([link])
        let load = self.local.fetchMyItems()
        let saveAndLoad = save.flatMap{ _ in load }
        let savedLink = self.waitFirstElement(expect, for: saveAndLoad.asObservable())?.first as? ReadLink
        
        // then
        XCTAssertEqual(savedLink?.uid, link.uid)
        XCTAssertEqual(savedLink?.ownerID, link.ownerID)
        XCTAssertEqual(savedLink?.parentID, link.parentID)
        XCTAssertEqual(savedLink?.link, link.link)
        XCTAssertEqual(savedLink?.createdAt, link.createdAt)
        XCTAssertEqual(savedLink?.lastUpdatedAt, link.lastUpdatedAt)
        XCTAssertEqual(savedLink?.customName, link.customName)
        XCTAssertEqual(savedLink?.priority, link.priority)
        XCTAssertEqual(savedLink?.categories.count, link.categories.count)
    }
    
    func testStorage_loadCollection() {
        // given
        let expect = expectation(description: "저장된 특정 콜렉션 로드")
        
        let dummyCollection = ReadCollection(name: "some")
        
        // when
        let save = self.local.updateReadItems([dummyCollection])
        let load = self.local.fetchCollection(dummyCollection.uid)
        let saveAndLoad = save.flatMap{ _ in load }
        let collection = self.waitFirstElement(expect, for: saveAndLoad.asObservable())
        
        // then
        XCTAssertNotNil(collection)
    }
}
