//
//  LocalFavoriteReadingListItemRepositoryImpleTests.swift
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


class LocalFavoriteReadingListItemRepositoryImpleTests: BaseTestCase {
    
    private var storage: SQLiteStorage!
    private var listRepository: LocalReadingListRepositoryImple!
    private var repository: LocalFavoriteReadingListItemRepositoryImple!
    
    override func setUpWithError() throws {
        self.storage = SQLiteStorageImple.testStorage("FavoriteItems")
        self.listRepository = .init(storage: self.storage)
        self.repository = .init(storage: self.storage)
    }
    
    override func tearDownWithError() throws {
        self.storage = nil
        self.listRepository = nil
        self.repository = nil
        SQLiteStorageImple.clearStorage("FavoriteItems")
    }
    
    private func makeRepository() -> LocalFavoriteReadingListItemRepositoryImple {
        return LocalFavoriteReadingListItemRepositoryImple(storage: self.storage)
    }
    
    private func dummyList(_ id: String) -> ReadingList {
        return ReadingList(uuid: id, name: "list:\(id)")
    }
    
    private func dummyLinkItem(_ id: String) -> ReadLinkItem {
        return ReadLinkItem(uuid: id, link: "link:\(id)")
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
        let lists = self.totalItemIDs.filter{ $0.starts(with: "list") }.map { self.dummyList($0) }
        let items = self.totalItemIDs.filter{ $0.starts(with: "item") }.map { self.dummyLinkItem($0) }
        try? await lists.asyncForEach { _ = try await self.listRepository.saveList($0, at: nil) }
        try? await items.asyncForEach { _ = try await self.listRepository.saveLinkItem($0, to: nil) }
        try? await self.oldFavoriteIDs.asyncForEach { try await self.repository.toggleIsFavorite(for: nil, $0, isOn: true) }
    }
}


extension LocalFavoriteReadingListItemRepositoryImpleTests {
    
    // load favorite ids
    func testRepository_loadFavoriteItemIDs() async {
        // given
        await self.saveOldItems()
        
        // when
        let ids = try? await self.repository.loadFavoriteItemIDs(for: nil)
        
        // then
        XCTAssertEqual(ids, self.oldFavoriteIDs)
    }
    
    // load favorite items
    func testRepository_loadFavoriteItems() async{
        // given
        await self.saveOldItems()
        
        // when
        let items = try? await self.repository.loadFavoriteItems(for: nil)
        
        // then
        let itemIDs = items?.map { $0.uuid }.sorted()
        XCTAssertEqual(itemIDs, self.oldFavoriteIDs.sorted())
    }
    
    // toggle is favorite -> on -> off
    func testRepository_toggleFavoriteIDToOff() async {
        // given
        await self.saveOldItems()
        let offID = self.oldFavoriteIDs.randomElement()!
        
        // when
        try? await self.repository.toggleIsFavorite(for: nil, offID, isOn: false)
        let ids = try? await self.repository.loadFavoriteItemIDs(for: nil)
        
        // then
        XCTAssertEqual(ids, self.oldFavoriteIDs.filter{ $0 != offID })
    }
    
    // toggle is favorite -> off -> on
    func testRepository_toggleFavoriteIDToOn() async {
        // given
        await self.saveOldItems()
        let newID = "item-new"
        
        // when
        try? await self.repository.toggleIsFavorite(for: nil, newID, isOn: true)
        let ids = try? await self.repository.loadFavoriteItemIDs(for: nil)
        
        // then
        XCTAssertEqual(ids, self.oldFavoriteIDs + [newID])
    }
}
