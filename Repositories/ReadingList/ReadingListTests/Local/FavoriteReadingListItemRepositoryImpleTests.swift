//
//  FavoriteReadingListItemLocalImpleTests.swift
//  ReadingListTests
//
//  Created by sudo.park on 2022/08/15.
//

import XCTest

import Domain
import Local
import Prelude
import Optics
import LocalDoubles
import UnitTestHelpKit

@testable import ReadingList


class FavoriteReadingListItemLocalImpleTests: BaseTestCase {
    
    private var storage: SQLiteStorage!
    private var local: FavoriteReadingListItemLocalImple!
    
    override func setUpWithError() throws {
        self.storage = SQLiteStorageImple.testStorage("FavoriteItems")
        self.local = .init(storage: self.storage)
    }
    
    override func tearDownWithError() throws {
        self.storage = nil
        self.local = nil
        SQLiteStorageImple.clearStorage("FavoriteItems")
    }
    
    private func makeLocal() -> FavoriteReadingListItemLocalImple {
        return FavoriteReadingListItemLocalImple(storage: self.storage)
    }
    
    private var oldFavoriteIDs: [String] {
        return ["list-1", "item-2", "list-100", "item-3"]
    }
    
    private var totalItemIDs: [String] {
        return self.oldFavoriteIDs + ["list-not", "item-not"]
    }
    
    private func saveOldItems() async {
        try? await self.storage.open()
        try? await self.storage.run { try $0.createTableOrNot(FavoriteReadingListItemIDTable.self) }
        try? await self.oldFavoriteIDs.asyncForEach { try await self.local.toggleIsFavorite($0, isOn: true) }
    }
}


extension FavoriteReadingListItemLocalImpleTests {
    
    // load favorite ids
    func testLocal_loadFavoriteItemIDs() async {
        // given
        await self.saveOldItems()
        
        // when
        let ids = try? await self.local.loadFavoriteItemIDs()
        
        // then
        XCTAssertEqual(ids, self.oldFavoriteIDs)
    }
    
    // toggle is favorite -> on -> off
    func testLocal_toggleFavoriteIDToOff() async {
        // given
        await self.saveOldItems()
        let offID = self.oldFavoriteIDs.randomElement()!
        
        // when
        try? await self.local.toggleIsFavorite(offID, isOn: false)
        let ids = try? await self.local.loadFavoriteItemIDs()
        
        // then
        XCTAssertEqual(ids, self.oldFavoriteIDs.filter{ $0 != offID })
    }
    
    // toggle is favorite -> off -> on
    func testLocal_toggleFavoriteIDToOn() async {
        // given
        await self.saveOldItems()
        let newID = "item-new"
        
        // when
        try? await self.local.toggleIsFavorite(newID, isOn: true)
        let ids = try? await self.local.loadFavoriteItemIDs()
        
        // then
        XCTAssertEqual(ids, self.oldFavoriteIDs + [newID])
    }
}
