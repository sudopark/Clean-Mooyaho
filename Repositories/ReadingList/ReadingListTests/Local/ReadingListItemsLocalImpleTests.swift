//
//  ReadingListItemsLocalImpleTests.swift
//  ReadingListTests
//
//  Created by sudo.park on 2022/08/17.
//

import XCTest

import Domain
import Local
import LocalDoubles

@testable import ReadingList

class ReadingListItemsLocalImpleTests: XCTestCase {
    
    private var storage: SQLiteStorage!
    private var local: ReadingListItemsLocalImple!
    
    override func setUpWithError() throws {
        self.storage = SQLiteStorageImple.testStorage("ReadingListItem")
        self.local = .init(storage: self.storage)
    }
    
    override func tearDownWithError() throws {
        self.storage = nil
        self.local = nil
        SQLiteStorageImple.clearStorage("FavoriteItems")
    }
    
    private func dummyList(_ id: String) -> ReadingList {
        return ReadingList(uuid: id, name: "list:\(id)")
    }
    
    private func dummyLinkItem(_ id: String) -> ReadLinkItem {
        return ReadLinkItem(uuid: id, link: "link:\(id)")
    }
}


extension ReadingListItemsLocalImpleTests {
 
    func testLocal_saveAndLoadItems() async {
        // given
        try? await self.storage.open()
        let lists = ["lst-1", "lst-2", "lst-3"].map { self.dummyList($0) }
        let links = ["lnk-1", "lnk-2"].map { self.dummyLinkItem($0) }
        
        // when
        try? await self.local.saveItems(lists + links)
        let items = try? await self.local.loadItems(in: ["lst-1", "lst-3", "lnk-2", "invalid"])
        
        // then
        let ids = items?.map { $0.uuid }
        XCTAssertEqual(ids, ["lst-1", "lst-3", "lnk-2"])
    }
}
