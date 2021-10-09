//
//  RepositoryTests+ItemCategory.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/10/09.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit

import DataStore


class RepositoryTests_ItemCategory: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var mockRemote: MockRemote!
    var mockLocal: MockLocal!
    
    var repository: TestingRepository!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.mockRemote = .init()
        self.mockLocal = .init()
        self.repository = .init(remote: self.mockRemote, local: self.mockLocal)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.mockLocal = nil
        self.mockRemote = nil
        self.repository = nil
    }
}


extension RepositoryTests_ItemCategory {
    
    func testRepo_fetchItemsFromLocal() {
        // given
        let expect = expectation(description: "로컬에서 카테고리 로드")
        self.mockLocal.register(key: "fetchCategories") {
            Maybe<[ItemCategory]>.just([ItemCategory(name: "some", colorCode: "")])
        }
        
        // when
        let loading = self.repository.fetchCategories(["some"])
        let categories = self.waitFirstElement(expect, for: loading.asObservable())
        
        // then
        XCTAssertEqual(categories?.count, 1)
    }
    
    func testRepo_updateCategoriesAtLocal() {
        // given
        let expect = expectation(description: "로컬에 카테고리 업데이트")
        self.mockLocal.register(key: "updateCategories") { Maybe<Void>.just() }
        
        // when
        let updating = self.repository.updateCategories([.init(name: "some", colorCode: "dd")])
        let result: Void? = self.waitFirstElement(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
}


extension RepositoryTests_ItemCategory {
    
    class TestingRepository: ItemCategoryRepository, ItemCategoryRepositoryDefImpleDependency {
        
        var disposeBag: DisposeBag = .init()
        
        var categoryRemote: ItemCategoryRemote
        
        var categoryLocal: ItemCategoryLocalStorage
        
        init(remote: ItemCategoryRemote, local: ItemCategoryLocalStorage) {
            self.categoryRemote = remote
            self.categoryLocal = local
        }
    }
}
