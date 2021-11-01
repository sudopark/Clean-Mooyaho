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
    
    func testCategory_updateCategories_withoutSignedIn() {
        // given
        let expect = expectation(description: "로그아웃 상태에서 카테고리 업데이트")
        self.mockRemote.signInMemberID = nil
        self.mockRemote.register(key: "requestUpdateCategories") { Maybe<Void>.empty() }
        self.mockLocal.register(key: "updateCategories") { Maybe<Void>.just() }
        
        // when
        let updating = self.repository.updateCategories([.init(name: "some", colorCode: "some")])
        let result: Void? = self.waitFirstElement(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testCategory_updateCategories_withSignedIn() {
        // given
        let expect = expectation(description: "로그인 상태에서 카테고리 업데이트")
        self.mockRemote.signInMemberID = "some"
        self.mockRemote.register(key: "requestUpdateCategories") { Maybe<Void>.just() }
        self.mockLocal.register(key: "updateCategories") { Maybe<Void>.just() }
        
        // when
        let updating = self.repository.updateCategories([.init(name: "some", colorCode: "some")])
        let result: Void? = self.waitFirstElement(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testCategory_whenUpdateCategoriesWithSignedIn_ignoreLocalError() {
        // given
        let expect = expectation(description: "로그인 상태에서 카테고리 업데이트시에 로컬에러는 무시")
        self.mockRemote.signInMemberID = "some"
        self.mockRemote.register(key: "requestUpdateCategories") { Maybe<Void>.just() }
        self.mockLocal.register(key: "updateCategories") { Maybe<Void>.error(LocalErrors.notExists) }
        
        // when
        let updating = self.repository.updateCategories([.init(name: "some", colorCode: "some")])
        let result: Void? = self.waitFirstElement(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testCategory_loadCategries_fromRemote() {
        // given
        let expect = expectation(description: "remote에서 카테고리 조회")
        self.mockRemote.register(key: "requestLoadCategories") { Maybe<[ItemCategory]>.just([.init(name: "some", colorCode: "some")]) }
        
        // when
        let loading = self.repository.requestLoadCategories(["some"])
        let categories = self.waitFirstElement(expect, for: loading.asObservable())
        
        // then
        XCTAssertEqual(categories?.count, 1)
    }
}

extension RepositoryTests_ItemCategory {
    
    func testRepo_suggestItemCategoryWithoutSignIn() {
        // given
        let expect = expectation(description: "로그아웃 상태에서 카테고리 서제스트 조회")
        self.mockRemote.register(key: "requestSuggestCategories") { Maybe<SuggestCategoryCollection>.empty() }
        self.mockLocal.register(key: "suggestCategories") { Maybe<[SuggestCategory]>.just([]) }
        
        // when
        let suggesting = self.repository.suggestItemCategory(name: "some", cursor: nil)
        let categories = self.waitFirstElement(expect, for: suggesting.asObservable())
        
        // then
        XCTAssertNotNil(categories)
    }
    
    func testRepo_suggestItemCategoryWithSignIn() {
        // given
        let expect = expectation(description: "로그아웃 상태에서 카테고리 서제스트 조회")
        self.mockRemote.register(key: "requestSuggestCategories") {
            Maybe<SuggestCategoryCollection>.just(.init(query: "some", categories: [], cursor: nil))
        }
        self.mockLocal.register(key: "suggestCategories") { Maybe<[SuggestCategory]>.empty() }
        
        // when
        let suggesting = self.repository.suggestItemCategory(name: "some", cursor: nil)
        let categories = self.waitFirstElement(expect, for: suggesting.asObservable())
        
        // then
        XCTAssertNotNil(categories)
    }
    
    func testRepo_loadLatestCategories_withoutSignin() {
        // given
        let expect = expectation(description: "로그아웃상태에서 최근 카테고리 조회")
        self.mockRemote.register(key: "requestLoadLastestCategories") {
            return Maybe<[SuggestCategory]>.empty()
        }
        self.mockLocal.register(key: "loadLatestCategories") {
            return Maybe<[SuggestCategory]>.just([])
        }
        
        // when
        let loading = self.repository.loadLatestCategories()
        let categories = self.waitFirstElement(expect, for: loading.asObservable())
        
        // then
        XCTAssertNotNil(categories)
    }
    
    func testRepo_loadLatestCategories_withSignin() {
        // given
        let expect = expectation(description: "로그인상태에서 최근 카테고리 조회")
        self.mockRemote.register(key: "requestLoadLastestCategories") {
            return Maybe<[SuggestCategory]>.just([])
        }
        self.mockLocal.register(key: "loadLatestCategories") {
            return Maybe<[SuggestCategory]>.empty()
        }
        
        // when
        let loading = self.repository.loadLatestCategories()
        let categories = self.waitFirstElement(expect, for: loading.asObservable())
        
        // then
        XCTAssertNotNil(categories)
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
