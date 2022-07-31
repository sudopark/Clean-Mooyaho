//
//  LocalReadingListRepositoryTests.swift
//  ReadingListTests
//
//  Created by sudo.park on 2022/07/09.
//

import XCTest

import Domain
import Local
import Prelude
import Optics
import LocalDoubles
import UnitTestHelpKit

import ReadingList


class LocalReadingListRepositoryTests: BaseTestCase {
    
    private var storage: SQLiteStorage!
    
    override func setUpWithError() throws {
        self.storage = SQLiteStorageImple.testStorage("readingList")
    }
    
    override func tearDownWithError() throws {
        self.storage = nil
        SQLiteStorageImple.clearStorage("readingList")
    }
    
    func makeRepository() -> LocalReadingListRepositoryImple {
        return LocalReadingListRepositoryImple(storage: self.storage)
    }
}


extension LocalReadingListRepositoryTests {
    
    private func dummyItems(size: Int = 5) -> [ReadingListItem] {
        let lists: [ReadingList] = (0..<size).map { int in
            return ReadingList(uuid: "list:\(int)", name: "list:\(int)", isRootList: false)
                |> \.createdAt .~ 100
                |> \.lastUpdatedAt .~ 200
                |> \.description .~ "description"
                |> \.categoryIds .~ ["c1", "c2"]
                |> \.priorityID .~ 100
        }
        let items: [ReadLinkItem] = (0..<size).map { int in
            return ReadLinkItem(uuid: "item:\(int)", link: "link:\(int)")
                |> \.createdAt .~ 100
                |> \.lastUpdatedAt .~ 200
                |> \.customName .~ "custom"
                |> \.categoryIds .~ ["c1", "c2"]
                |> \.priorityID .~ 100
                |> \.isRead .~ true
        }
        
        return lists + items
    }
    
    func testStorage_saveAndLoadMyLists() async {
        // given
        try? await self.storage.open()
        let repository = self.makeRepository()
        let lists = self.dummyItems().compactMap { $0 as? ReadingList }
        let links = self.dummyItems().compactMap { $0 as? ReadLinkItem }
        
        // when
        try? await lists.asyncForEach { _ = try await repository.saveList($0, at: nil) }
        try? await links.asyncForEach { _ = try await repository.saveLinkItem($0, to: nil) }
        let myList = try? await repository.loadMyList(for: nil)
        
        // then
        XCTAssertEqual(myList?.items.map { $0.uuid }, lists.map { $0.uuid } + links.map { $0.uuid })
    }
    
    func testStorage_saveNormalListAndLoad() async {
        // given
        try? await self.storage.open()
        let repository = self.makeRepository()
        let lists = self.dummyItems().compactMap { $0 as? ReadingList }
        let links = self.dummyItems().compactMap { $0 as? ReadLinkItem }
        let dummyList = ReadingList(uuid: "some", name: "sub list", isRootList: false)
        
        // when
        _ = try? await repository.saveList(dummyList, at: nil)
        try? await lists.asyncForEach { _ = try await repository.saveList($0, at: dummyList.uuid) }
        try? await links.asyncForEach { _ = try await repository.saveLinkItem($0, to: dummyList.uuid) }
        let list = try? await repository.loadList(dummyList.uuid)
        
        // then
        XCTAssertEqual(list?.uuid, "some")
        XCTAssertEqual(list?.name, "sub list")
        XCTAssertEqual(list?.items.map { $0.uuid }, lists.map { $0.uuid } + links.map { $0.uuid })
    }
    
    func testStorage_assertSavedList() async {
        // given
        try? await self.storage.open()
        let repository = self.makeRepository()
        let dummyList = self.dummyItems().first as! ReadingList
            |> \.ownerID .~ "owner"
        
        // when
        _ = try? await repository.saveList(dummyList, at: nil)
        let list = try? await repository.loadList(dummyList.uuid)
        
        // then
        XCTAssertEqual(list?.uuid, "list:0")
        XCTAssertEqual(list?.name, "list:0")
        XCTAssertEqual(list?.ownerID, "owner")
        XCTAssertEqual(list?.isRootList, false)
        XCTAssertEqual(list?.createdAt, 100)
        XCTAssertEqual(list?.lastUpdatedAt, 200)
        XCTAssertEqual(list?.description, "description")
        XCTAssertEqual(list?.categoryIds, ["c1", "c2"])
        XCTAssertEqual(list?.priorityID, 100)
    }
    
    func testStorage_assertSavedLinkItem() async {
        // given
        try? await self.storage.open()
        let repository = self.makeRepository()
        let dummyItem = self.dummyItems().compactMap{ $0 as? ReadLinkItem }.first!
            |> \.ownerID .~ "owner"
        
        // when
        _ = try? await repository.saveLinkItem(dummyItem, to: "parent_list")
        let link = try? await repository.loadLinkItem(dummyItem.uuid)
        
        // then
        XCTAssertEqual(link?.uuid, "item:0")
        XCTAssertEqual(link?.link, "link:0")
        XCTAssertEqual(link?.listID, "parent_list")
        XCTAssertEqual(link?.ownerID, "owner")
        XCTAssertEqual(link?.createdAt, 100)
        XCTAssertEqual(link?.lastUpdatedAt, 200)
        XCTAssertEqual(link?.customName, "custom")
        XCTAssertEqual(link?.categoryIds, ["c1", "c2"])
        XCTAssertEqual(link?.priorityID, 100)
        XCTAssertEqual(link?.isRead, true)
    }
}


extension LocalReadingListRepositoryTests {
    
    func testStorage_updateSavedList() async {
        // given
        try? await self.storage.open()
        let repository = self.makeRepository()
        let dummyList = self.dummyItems().first as! ReadingList
        let newList = dummyList
            |> \.ownerID .~ "new_owner"
            |> \.name .~ "new_name"
            |> \.createdAt .~ 1
            |> \.lastUpdatedAt .~ 2
            |> \.description .~ "new_desc"
            |> \.categoryIds .~ []
            |> \.priorityID .~ nil
        
        // when
        _ = try? await repository.saveList(dummyList, at: nil)
        _ = try? await repository.updateList(newList)
        let list = try? await repository.loadList(newList.uuid)
        
        // then
        XCTAssertEqual(list?.uuid, "list:0")
        XCTAssertEqual(list?.name, "new_name")
        XCTAssertEqual(list?.ownerID, "new_owner")
        XCTAssertEqual(list?.isRootList, false)
        XCTAssertEqual(list?.createdAt, 1)
        XCTAssertEqual(list?.lastUpdatedAt, 2)
        XCTAssertEqual(list?.description, "new_desc")
        XCTAssertEqual(list?.categoryIds, [])
        XCTAssertEqual(list?.priorityID, nil)
    }
    
    func testStorage_updateLinkItem() async {
        // given
        try? await self.storage.open()
        let repostiory = self.makeRepository()
        let dummyItem = self.dummyItems().compactMap { $0 as? ReadLinkItem }.first!
        let newItem = dummyItem
            |> \.ownerID .~ "new_owner"
            |> \.listID .~ "new_parent"
            |> \.createdAt .~ 1
            |> \.lastUpdatedAt .~ 2
            |> \.customName .~ "new_name"
            |> \.priorityID .~ nil
            |> \.categoryIds .~ []
            |> \.isRead .~ false
        
        // when
        _ = try? await repostiory.saveLinkItem(dummyItem, to: nil)
        _ = try? await repostiory.updateLinkItem(newItem)
        let link = try? await repostiory.loadLinkItem(newItem.uuid)
        
        // then
        XCTAssertEqual(link?.uuid, "item:0")
        XCTAssertEqual(link?.link, "link:0")
        XCTAssertEqual(link?.listID, "new_parent")
        XCTAssertEqual(link?.ownerID, "new_owner")
        XCTAssertEqual(link?.createdAt, 1)
        XCTAssertEqual(link?.lastUpdatedAt, 2)
        XCTAssertEqual(link?.customName, "new_name")
        XCTAssertEqual(link?.categoryIds, [])
        XCTAssertEqual(link?.priorityID, nil)
        XCTAssertEqual(link?.isRead, false)
    }
    
    func testStorage_deleteSavedList() async {
        // given
        try? await self.storage.open()
        let repository = self.makeRepository()
        let dummyList = self.dummyItems().first as! ReadingList
        
        // when
        _ = try? await repository.saveList(dummyList, at: nil)
        try? await repository.removeList(dummyList.uuid)
        let list = try? await repository.loadList(dummyList.uuid)
        
        // then
        XCTAssertNil(list)
    }
    
    func testStorage_deleteLinkItem() async {
        // given
        try? await self.storage.open()
        let repository = self.makeRepository()
        let dummyItem = ReadLinkItem.make("some")
        
        // when
        _ = try? await repository.saveLinkItem(dummyItem, to: nil)
        try? await repository.removeLinkItem(dummyItem.uuid)
        let link = try? await repository.loadLinkItem(dummyItem.uuid)
        
        // then
        XCTAssertNil(link)
    }
}
