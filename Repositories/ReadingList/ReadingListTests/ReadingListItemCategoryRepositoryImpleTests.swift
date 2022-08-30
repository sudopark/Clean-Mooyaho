//
//  ReadingListItemCategoryRepositoryImpleTests.swift
//  ReadingListTests
//
//  Created by sudo.park on 2022/08/30.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import Extensions
import UnitTestHelpKit

import ReadingList


class ReadingListItemCategoryRepositoryImpleTests_signOutCase: BaseTestCase {
    
    private var mockLocal: StubLocal!
    
    override func setUpWithError() throws {
        self.mockLocal = .init()
    }
    
    override func tearDownWithError() throws {
        self.mockLocal = nil
    }
    
    private func makeRepository() -> ReadingListItemCategoryRepositoryImple {
        let authInfoProvider = AuthInfoProviderImple(auth: nil)
        return .init(
            authInfoProvider: authInfoProvider,
            local: self.mockLocal,
            remote: StubRemote()
        )
    }
}

extension ReadingListItemCategoryRepositoryImpleTests_signOutCase {
    
    func testRepository_loadCategoriesByIDs() async {
        // given
        let repository = self.makeRepository()
        
        // when
        let categories = try? await repository.loadCategories(in: ["c:0", "c:0"])
        
        // then
        XCTAssertEqual(categories?.map { $0.uid }, ["c:0", "c:1"])
    }
    
    func testRepository_loadCategoriesByIDsFail() async {
        // given
        let repository = self.makeRepository()
        self.mockLocal.loadCategoriesRsult = .failure(RuntimeError("failed"))
        
        // when + then
        let categories = try? await repository.loadCategories(in: ["c1", "c2"])
        
        // then
        XCTAssertEqual(categories?.map { $0.uid }, [])
    }
    
    // load categories earilerThan
    func testRepository_loadCategoriesEarilerThan() async {
        // given
        let repositoty = self.makeRepository()
        
        // when
        let categories = try? await repositoty.loadCategories(earilerThan: .now(), pageSize: 10)
        
        // then
        XCTAssertNotNil(categories)
    }
    
    // load categories earilerThan fail
    func testRepository_loadCategoriesEarilerThanFail() async {
        // given
        let repositoty = self.makeRepository()
        self.mockLocal.loadCategoriesearilerThanResult = .failure(RuntimeError("failed"))
        
        // when
        let categories = try? await repositoty.loadCategories(earilerThan: .now(), pageSize: 10)
        
        // then
        XCTAssertNil(categories)
    }
    
    // find category
    func testRepository_findCategory() async {
        // given
        let repository = self.makeRepository()
        
        // when
        let category = try? await repository.findCategory(by: "name")
        
        // then
        XCTAssertNotNil(category)
    }
    
    // find category fail
    func testRepository_findCategoryFail() async {
        // given
        let repository = self.makeRepository()
        self.mockLocal.findCategoryResult = .failure(RuntimeError("failed"))
        
        // when + then
        do {
            let _ = try await repository.findCategory(by: "name")
            XCTFail("조회가 실패해야만함")
        } catch {
            XCTAssert(true)
        }
    }
    
    // save categories
    func testRepository_saveCategories() async {
        // given
        let repository = self.makeRepository()
        
        // when + then
        do {
            try await repository.saveCategories([.dummy(0)])
            XCTAssert(true)
        } catch {
            XCTFail("저장이 성공 해야만함")
        }
    }
    
    // save categories fail
    func testRepository_saveCategoriesFail() async {
        // given
        let repository = self.makeRepository()
        self.mockLocal.saveCategoriesResult = .failure(RuntimeError("failed"))
        
        // when + then
        do {
            try await repository.saveCategories([.dummy(0)])
            XCTFail("저장이 실패 해야만함")
        } catch {
            XCTAssert(true)
        }
    }
    
    // update category
    func testRepository_updateCategory() async {
        // given
        let repository = self.makeRepository()
        
        // when
        let updated = try? await repository.updateCategory(.dummy(0))
        
        // then
        XCTAssertNotNil(updated)
    }
    
    // update categories fail
    func testRepository_updateCategoryFail() async {
        // given
        let repository = self.makeRepository()
        self.mockLocal.updateCategoryResult = .failure(RuntimeError("some"))
        
        // when
        let updated = try? await repository.updateCategory(.dummy(0))
        
        // then
        XCTAssertNil(updated)
    }
    
    // remove category
    func testRepository_removeCategory() async {
        // given
        let repository = self.makeRepository()
        
        // when + then
        do {
            try await repository.removeCategory("some")
            XCTAssert(true)
        } catch {
            XCTFail("제거가 성공 해야함")
        }
    }
    
    // remove categories fail
    func testRepository_removeCategoryFail() async {
        // given
        let repository = self.makeRepository()
        self.mockLocal.removeCategoryResult = .failure(RuntimeError("failed"))
        
        // when + then
        do {
            try await repository.removeCategory("some")
            XCTFail("제거가 실패 해야함")
        } catch {
            XCTAssert(true)
        }
    }
}


// Stubs

private final class StubLocal: ReadingListItemCategoryLocal, @unchecked Sendable {
    
    var loadCategoriesRsult: Result<[ReadingListItemCategory], Error> = .success(
        (0..<2).map { .dummy($0) }
    )
    func loadCategories(in ids: [String]) async throws -> [ReadingListItemCategory] {
        return try self.loadCategoriesRsult.unwrapSuccessOrThrowWithoutCasting()
    }
    
    var loadCategoriesearilerThanResult: Result<[ReadingListItemCategory], Error> = .success(
        (0..<10).map { .dummy($0) }
    )
    func loadCategories(earilerThan creatTime: Extensions.TimeStamp, pageSize: Int) async throws -> [ReadingListItemCategory] {
        return try loadCategoriesearilerThanResult.unwrapSuccessOrThrowWithoutCasting()
    }
    
    var findCategoryResult: Result<ReadingListItemCategory?, Error> = .success(
        .dummy(0)
    )
    func findCategory(by name: String) async throws -> ReadingListItemCategory? {
        return try findCategoryResult.unwrapSuccessOrThrowWithoutCasting()
    }
    
    var didSaveCategories: [ReadingListItemCategory]?
    var saveCategoriesResult: Result<Void, Error> = .success(())
    func saveCategories(_ categories: [ReadingListItemCategory]) async throws {
        self.didSaveCategories = categories
        try self.saveCategoriesResult.throwOrNot()
    }
    
    var didUpdatedCategories: ReadingListItemCategory?
    var updateCategoryResult: Result<Void, Error> = .success(())
    func updateCategory(_ category: ReadingListItemCategory) async throws -> ReadingListItemCategory {
        self.didUpdatedCategories = category
        return try self.updateCategoryResult.map { category }.unwrapSuccessOrThrowWithoutCasting()
    }
    
    var didRemoveCategoryID: String?
    var removeCategoryResult: Result<Void, Error> = .success(())
    func removeCategory(_ uid: String) async throws {
        self.didRemoveCategoryID = uid
        try self.removeCategoryResult.throwOrNot()
    }
}

private final class StubRemote: ReadingListItemCategoryRemote, @unchecked Sendable {
    
    var loadCategoriesRsult: Result<[ReadingListItemCategory], Error> = .success(
        (100..<102).map { .dummy($0) }
    )
    func loadCategories(in ids: [String]) async throws -> [ReadingListItemCategory] {
        return try self.loadCategoriesRsult.unwrapSuccessOrThrowWithoutCasting()
    }
    
    var loadCategoriesearilerThanResult: Result<[ReadingListItemCategory], Error> = .success(
        (100..<110).map { .dummy($0) }
    )
    func loadCategories(for ownerID: String, earilerThan creatTime: Extensions.TimeStamp, pageSize: Int) async throws -> [ReadingListItemCategory] {
        return try loadCategoriesearilerThanResult.unwrapSuccessOrThrowWithoutCasting()
    }
    
    var findCategoryResult: Result<ReadingListItemCategory?, Error> = .success(
        .dummy(100)
    )
    func findCategory(for ownerID: String, by name: String) async throws -> ReadingListItemCategory? {
        return try findCategoryResult.unwrapSuccessOrThrowWithoutCasting()
    }
    
    var saveCategoriesResult: Result<Void, Error> = .success(())
    func saveCategories(for ownerID: String, _ categories: [ReadingListItemCategory]) async throws {
        try self.saveCategoriesResult.throwOrNot()
    }
    
    var updateCategoryResult: Result<Void, Error> = .success(())
    func updateCategory(for ownerID: String, _ category: ReadingListItemCategory) async throws -> ReadingListItemCategory {
        return try self.updateCategoryResult.map { category }.unwrapSuccessOrThrowWithoutCasting()
    }
    
    var removeCategoryResult: Result<Void, Error> = .success(())
    func removeCategory(_ uid: String) async throws {
        try self.removeCategoryResult.throwOrNot()
    }
}


private extension ReadingListItemCategory {
    
    static func dummy(_ int: Int) -> ReadingListItemCategory {
        return .init(uid: "c:\(int)", name: "", colorCode: "", createdAt: 0)
    }
}
