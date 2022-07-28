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
        let items = self.dummyItems().compactMap { $0 as? ReadingList }
        
        // when
        try? await items.asyncForEach { _ = try await repository.saveList($0, at: nil) }
        let myList = try? await repository.loadMyList(for: nil)
        
        // then
        XCTAssertEqual(myList?.items.map { $0.uuid }, items.map { $0.uuid })
    }
    
    func testStorage_saveNormalListAndLoad() async {
        // given
        try? await self.storage.open()
        let repository = self.makeRepository()
        let items = self.dummyItems().compactMap { $0 as? ReadingList }
        let dummyList = ReadingList(uuid: "some", name: "sub list", isRootList: false)
            |> \.items .~ items
        
        // when
        _ = try? await repository.saveList(dummyList, at: nil)
        try? await items.asyncForEach { _ = try await repository.saveList($0, at: dummyList.uuid) }
        let list = try? await repository.loadList(dummyList.uuid)
        
        // then
        XCTAssertEqual(list?.uuid, "some")
        XCTAssertEqual(list?.name, "sub list")
        XCTAssertEqual(list?.items.map { $0.uuid }, items.map { $0.uuid })
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
}
