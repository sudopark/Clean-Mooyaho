//
//  ReadingListTests.swift
//  ReadingListTests
//
//  Created by sudo.park on 2022/06/25.
//

import XCTest

import Prelude
import Optics

import Extensions

@testable import ReadingList

class ReadingListTests: XCTestCase {


    func test_makeRootList() {
        // given
        // when
        let list = ReadingList.makeMyRootList("some")
        
        // then
        XCTAssertEqual(list.isRootList, true)
    }
    
    func testList_appendItem() {
        // given
        let list = ReadingList.makeList("some", ownerID: "owner")
        
        // when
        let item = ReadLinkItem(uuid: "some")
        let newList = list.appendItem(item)
        
        // then
        XCTAssertEqual(newList.items.count, 1)
    }
    
    private var dummyList: ReadingList {
        let items = (0..<10).map { ReadLinkItem(uuid: "some:\($0)") }
        return ReadingList.makeMyRootList("some")
            |> \.items .~ items
    }
    
    func testList_updateItem() {
        // given
        let list = self.dummyList
        
        // when
        let item2 = ReadLinkItem(uuid: "some:2")
        |> \.customName .~ "custom name"
        
        let newList = try? list.updateItem(item2)
        
        // then
        let updatedItem2 = newList?.items.first(where: { $0.uuid == item2.uuid })
        XCTAssertEqual((updatedItem2 as? ReadLinkItem)?.customName, "custom name")
    }
    
    func testList_updateItem_byID() {
        // given
        let list = self.dummyList
        
        // when
        let newList = try? list.updateItem(itemID: "some:2") {
            guard let item = $0 as? ReadLinkItem else { return $0 }
            return item |> \.customName .~ "custom name"
        }
        
        // then
        let updatedItem2 = newList?.items.first(where: { $0.uuid == "some:2" })
        XCTAssertEqual((updatedItem2 as? ReadLinkItem)?.customName, "custom name")
    }
    
    func testList_removeItem() {
        // given
        let list = self.dummyList
        
        // when
        let newList = try? list.removeItem("some:2")
        
        // then
        XCTAssertEqual(newList?.items.count, 9)
        XCTAssertNil(newList?.items.first(where: { $0.uuid == "some:2" } ))
    }
}
