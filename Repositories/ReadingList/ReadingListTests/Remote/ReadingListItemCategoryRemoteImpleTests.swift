//
//  ReadingListItemCategoryRemoteImpleTests.swift
//  ReadingListTests
//
//  Created by sudo.park on 2022/08/29.
//

import XCTest

import Domain
import Remote
import Extensions
import UnitTestHelpKit
import RemoteDoubles
import Prelude
import Optics

@testable import ReadingList


class ReadingListItemCategoryRemoteImpleTests: BaseTestCase {
    
    private var spyRemote: MockRestRemote!
    
    override func setUpWithError() throws {
        self.spyRemote = .init()
    }
    
    override func tearDownWithError() throws {
        self.spyRemote = nil
    }
    
    private var dummyCategories: [MemberItemCategory] {
        return (0..<10).map { int -> MemberItemCategory in
            let category = ReadingListItemCategory(
                uid: "u:\(int)",
                name: "n:\(int)",
                colorCode: "c:\(int)",
                createdAt: TimeStamp(int)
            )
            return .init("some", category)
        }
    }
    
    private func makeRemote() -> ReadingListItemCategoryRemoteImple {
        
        self.spyRemote.findByQueryResult = .success(self.dummyCategories)
        self.spyRemote.batchSaveResult = .success(())
        self.spyRemote.updateResult = .success(self.dummyCategories.first!)
        self.spyRemote.deleteResult = .success(())
        return .init(restRemote: self.spyRemote)
    }
}


extension ReadingListItemCategoryRemoteImpleTests {
    
    // load ids in
    func testRemote_loadCategories_byIDs() async {
        // given
        let remote = self.makeRemote()
        
        // when
        let categories = try? await remote.loadCategories(in: ["c:1", "c:2"])
        
        // then
        XCTAssertEqual(categories?.isNotEmpty, true)
        let path = self.spyRemote.didRequestedFindByQueryEndpoints.first?.path
        let method = self.spyRemote.didRequestedFindByQueryEndpoints.first?.method
        let conditions = self.spyRemote.didRequestedFindByQuerys.first?.matchingQuery.conditions.map { $0.stringValue }
        XCTAssertEqual(path, "reading_list/categories")
        XCTAssertEqual(method, .get)
        XCTAssertEqual(conditions, ["uid in [\"c:1\", \"c:2\"]"])
    }
    
    // load by ordering + create time
    func testRemote_loadCategories_withOrderingByCreateTime() async {
        // given
        let remote = self.makeRemote()
        
        // when
        let categories = try? await remote.loadCategories(for: "some", earilerThan: 300, pageSize: 10)
        
        // then
        XCTAssertEqual(categories?.isNotEmpty, true)
        let path = self.spyRemote.didRequestedFindByQueryEndpoints.first?.path
        let method = self.spyRemote.didRequestedFindByQueryEndpoints.first?.method
        let conditions = self.spyRemote.didRequestedFindByQuerys.first?.matchingQuery.conditions.map { $0.stringValue }
        let limit = self.spyRemote.didRequestedFindByQuerys.first?.limit
        XCTAssertEqual(path, "reading_list/categories")
        XCTAssertEqual(method, .get)
        XCTAssertEqual(conditions, ["oid = some", "ct < 300.0"])
        XCTAssertEqual(limit, 10)
    }
    
    // load by name -> find
    func testRemote_loadCategory_byName() async {
        // given
        let remote = self.makeRemote()
        
        // when
        let category = try? await remote.loadCategory(for: "some", by: "name")
        
        // then
        XCTAssertNotNil(category)
        let path = self.spyRemote.didRequestedFindByQueryEndpoints.first?.path
        let method = self.spyRemote.didRequestedFindByQueryEndpoints.first?.method
        let conditions = self.spyRemote.didRequestedFindByQuerys.first?.matchingQuery.conditions.map { $0.stringValue }
        XCTAssertEqual(path, "reading_list/categories")
        XCTAssertEqual(method, .get)
        XCTAssertEqual(conditions, ["oid = some", "nm = name"])
    }
}


extension ReadingListItemCategoryRemoteImpleTests {
    
    // request batch save
    func testRemote_batchSaveCategories() async {
        // given
        let remote = self.makeRemote()
        
        // when
        try? await remote.saveCategories(for: "some", self.dummyCategories.map { $0.category })
        
        // then
        let path = self.spyRemote.didRequestedBatchSaveEndpoints.first?.path
        let method = self.spyRemote.didRequestedBatchSaveEndpoints.first?.method
        let jsons = self.spyRemote.didRequestedBatchSaveEntities.first
        XCTAssertEqual(path, "reading_list/categories")
        XCTAssertEqual(method, .post)
        XCTAssertEqual(jsons?.count, 10)
    }
    
    // request update
    func testRemote_updateCategory() async {
        // given
        let remote = self.makeRemote()
        
        // when
        let newCategory = self.dummyCategories.first!.category
            |> \.name .~ "new name"
            |> \.colorCode .~ "new code"
        _ = try? await remote.updateCategory(for: "some", newCategory)
        
        // then
        let path = self.spyRemote.didRequestedUpdateEndpoints.first?.path
        let method = self.spyRemote.didRequestedUpdateEndpoints.first?.method
        let id = self.spyRemote.didRequestedUpdateIDs.first
        let json = self.spyRemote.didRequestedUpdateTOJsons.first ?? [:]
        XCTAssertEqual(path, "reading_list/categories")
        XCTAssertEqual(method, .put)
        XCTAssertEqual(id, "u:0")
        XCTAssertEqual(json["nm"] as? String, "new name")
        XCTAssertEqual(json["cc"] as? String, "new code")
    }
    
    // request delete
    func testRemote_removeCategory() async {
        // given
        let remote = self.makeRemote()
        
        // when
        try? await remote.removeCategory("some")
        
        // then
        let path = self.spyRemote.didRequestDeleteByIDEndpoints.first?.path
        let method = self.spyRemote.didRequestDeleteByIDEndpoints.first?.method
        let id = self.spyRemote.didRequestDeleteByIDs.first
        XCTAssertEqual(path, "reading_list/categories")
        XCTAssertEqual(method, .delete)
        XCTAssertEqual(id, "some")
    }
}
