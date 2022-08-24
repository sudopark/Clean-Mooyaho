//
//  ReadingListItemCategoryLocalImpleTests.swift
//  ReadingListTests
//
//  Created by sudo.park on 2022/08/24.
//

import XCTest

import Domain
import Local
import LocalDoubles
import Prelude
import Optics

@testable import ReadingList


class ReadingListItemCategoryLocalImpleTests: XCTestCase {
    
    private var storage: SQLiteStorage!
    private var local: ReadingListItemCategoryLocalImple!
    
    override func setUpWithError() throws {
        self.storage = SQLiteStorageImple.testStorage("Categories")
        self.local = .init(storage: self.storage)
    }
    
    override func tearDownWithError() throws {
        self.storage = nil
        self.local = nil
        SQLiteStorageImple.clearStorage("Categories")
    }
    
    private var dummyCategories: [ReadingListItemCategory] {
        return (0..<10).map { int -> ReadingListItemCategory in
            return .init(uid: "c:\(int)", name: "cate:\(int)", colorCode: "color:\(int)", createdAt: 10 - Double(int))
        }
    }
}


extension ReadingListItemCategoryLocalImpleTests {
    
    func testLocal_saveAndLoadCategories() async {
        // given
        try? await self.storage.open()
        
        // when
        try? await self.local.saveCategories(self.dummyCategories)
        let categories = try? await self.local.loadCategories(in: ["c:1", "c:4", "c:8"])
        
        // then
        XCTAssertEqual(categories?.count, 3)
        let category1 = categories?.first
        XCTAssertEqual(category1?.uid, "c:1")
        XCTAssertEqual(category1?.name, "cate:1")
        XCTAssertEqual(category1?.colorCode, "color:1")
        XCTAssertEqual(category1?.createdAt, 9)
    }
    
    func testLocal_loadCategoriesWithOrderingByCreateTime() async {
        // given
        try? await self.storage.open()
        
        // when
        try? await self.local.saveCategories(self.dummyCategories)
        let categories = try? await self.local.loadCategories(earilerThan: 7, pageSize: 3)
        
        // then
        let ids = categories?.map { $0.uid }
        XCTAssertEqual(ids, ["c:4", "c:5", "c:6"])
    }
    
    func testLocal_findCategoryByName() async {
        // given
        try? await self.storage.open()
        
        // when
        try? await self.local.saveCategories(self.dummyCategories)
        let category = try? await self.local.findCategory(by: "cate:3")
        
        // then
        XCTAssertEqual(category?.uid, "c:3")
    }
    
    func testLocal_updateCategory() async {
        // given
        try? await self.storage.open()
        
        // when
        let category = self.dummyCategories.first!
        try? await self.local.saveCategories(self.dummyCategories)
        
        let newCategory = category
            |> \.name .~ "new name"
            |> \.colorCode .~ "new color"
        _ = try? await self.local.updateCategory(newCategory)
        let loadCategory = try? await self.local.findCategory(by: "new name")
        
        // then
        XCTAssertEqual(loadCategory?.uid, "c:0")
        XCTAssertEqual(loadCategory?.name, "new name")
        XCTAssertEqual(loadCategory?.colorCode, "new color")
    }
    
    func testLocal_removeCategory() async {
        // given
        try? await self.storage.open()
        
        // when
        try? await self.local.saveCategories(self.dummyCategories)
        try? await self.local.removeCategory("c:4")
        let categories = try? await self.local.loadCategories(in: self.dummyCategories.map { $0.uid } )
        
        // then
        XCTAssertEqual(categories?.count, 9)
        XCTAssertEqual(categories?.first(where: { $0.uid == "c:4" }) == nil, true)
    }
}
