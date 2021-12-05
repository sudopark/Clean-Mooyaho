//
//  RepositoryTests+ItemCategory.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/10/09.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift
import Prelude
import Optics

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
    
    func testRepo_loadWithPaging_witoutSignIn() {
        // given
        let expect = expectation(description: "로그아웃 상태에서 카테고리 페이징 조회")
        self.mockLocal.register(key: "fetchCategories:earilerThan") {
            Maybe<[ItemCategory]>.just([.init(name: "some", colorCode: "c")])
        }
        
        // when
        let load = self.repository.requestLoadCategories(earilerThan: .now(), pageSize: 30)
        let categories = self.waitFirstElement(expect, for: load.asObservable())
        
        // then
        XCTAssertEqual(categories?.count, 1)
    }
    
    func testRepo_deleteCategory_withoutSignIn() {
        // given
        let expect = expectation(description: "로그아웃 상태에서 카테고리 삭제")
        self.mockLocal.register(key: "deleteCategory") { Maybe<Void>.just() }
        
        // when
        let delete = self.repository.requestDeleteCategory("some")
        let result: Void? = self.waitFirstElement(expect, for: delete.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepo_loadWithPaging_withSignIn() {
        // given
        let expect = expectation(description: "로그인상태에서 카테고리 페이징으로 로드")
        self.mockRemote.register(key: "requestLoadCategories:earilerThan") {
            Maybe<[ItemCategory]>.just([.init(name: "some", colorCode: "c")])
        }
        
        // when
        let load = self.repository.requestLoadCategories(earilerThan: .now(), pageSize: 30)
        let categories = self.waitFirstElement(expect, for: load.asObservable())
        
        // then
        XCTAssertEqual(categories?.count, 1)
    }
    
    func testRepo_whenLoadWithPagingWithSignIn_updateLocal() {
        // given
        let expect = expectation(description: "로그인상태에서 카테고리 페이징으로 로드사에 로컬에도 저장")
        self.mockRemote.register(key: "requestLoadCategories:earilerThan") {
            Maybe<[ItemCategory]>.just([.init(name: "some", colorCode: "c")])
        }
        self.mockLocal.register(key: "updateCategories") { Maybe<Void>.just() }
        self.mockLocal.called(key: "updateCategories") { _ in
            expect.fulfill()
        }
        
        // when
        self.repository.requestLoadCategories(earilerThan: .now(), pageSize: 30)
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testRepo_deleteCategory_withSignIn() {
        // given
        let expect = expectation(description: "로그인 상태에서 카테고리 삭제")
        self.mockRemote.register(key: "requestDeleteCategory") { Maybe<Void>.just() }
        self.mockLocal.register(key: "deleteCategory") { Maybe<Void>.just() }
        
        // when
        let delete = self.repository.requestDeleteCategory("some")
        let result: Void? = self.waitFirstElement(expect, for: delete.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepo_whenDeleteCategory_alsoDeleteFromLocal() {
        // given
        let expect = expectation(description: "로그인상태에서 카테고리 삭제시에 로컬에도 삭제")
        self.mockRemote.register(key: "requestDeleteCategory") { Maybe<Void>.just() }
        self.mockLocal.register(key: "deleteCategory") { Maybe<Void>.just() }
        self.mockLocal.called(key: "deleteCategory") { _ in
            expect.fulfill()
        }
        
        // when
        self.repository.requestDeleteCategory("some")
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testRepository_findCategoryWithoutSignIn() {
        // given
        let expect = expectation(description: "로그아웃상태에서 이름으로 카테고리 찾기")
        self.mockLocal.register(key: "findCategory") {
            Maybe<ItemCategory?>.just(ItemCategory.init(name: "some", colorCode: "cc"))
        }
        
        // when
        let finding = self.repository.findCategory("some")
        let category = self.waitFirstElement(expect, for: finding.asObservable())
        
        // then
        XCTAssertNotNil(category)
    }
    
    func testRepository_findCategoryWithSignIn() {
        // given
        let expect = expectation(description: "로그인 상태에서 카테고리 아이템 찾기")
        self.mockRemote.register(key: "requestFindCategory") {
            Maybe<ItemCategory?>.just(ItemCategory.init(name: "some", colorCode: "cc"))
        }
        
        // when
        let finding = self.repository.findCategory("some")
        let category = self.waitFirstElement(expect, for: finding.asObservable())
        
        // then
        XCTAssertNotNil(category)
    }
    
    func testReopsitory_whenFindCategoryWithSignIn_updateLocal() {
        // given
        let expect = expectation(description: "로그인상태에서 카테고리 찾기시에 로컬 업데이트")
        self.mockRemote.register(key: "requestFindCategory") {
            Maybe<ItemCategory?>.just(ItemCategory.init(name: "some", colorCode: "cc"))
        }
        self.mockLocal.register(key: "updateCategories") { Maybe<Void>.just() }
        self.mockLocal.called(key: "updateCategories") { _ in
            expect.fulfill()
        }
        
        // when
        self.repository.findCategory("some")
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testRepository_updateItemByParams_withoutSignIn() {
        // given
        let expect = expectation(description: "로그아웃 상태에서 파라미터로 카테고리 업데이트")
        self.mockLocal.register(key: "updateCategory") { Maybe<Void>.just() }
        
        // when
        let params = UpdateCategoryAttrParams(uid: "some") |> \.newName .~ "new name"
        let updating = self.repository.updateCategory(by: params)
        let result: Void? = self.waitFirstElement(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepository_updateItemByParams_withSignIn() {
        // given
        let expect = expectation(description: "로그인 상태에서 파라미터로 카테고리 업데이트")
        self.mockLocal.register(key: "updateCategory") { Maybe<Void>.just() }
        self.mockRemote.register(key: "requestUpdateCategory") { Maybe<Void>.just() }
        
        // when
        let params = UpdateCategoryAttrParams(uid: "some") |> \.newName .~ "new name"
        let updating = self.repository.updateCategory(by: params)
        let result: Void? = self.waitFirstElement(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepository_whenUpdateItemByParamsWithSignIn_updateLocal() {
        // given
        let expect = expectation(description: "로그인 상태에서 파라미터로 카테고리 업데이트시에 로컬도 업데이트")
        self.mockLocal.register(key: "updateCategory") { Maybe<Void>.just() }
        self.mockRemote.register(key: "requestUpdateCategory") { Maybe<Void>.just() }
        self.mockLocal.called(key: "updateCategory") { _ in
            expect.fulfill()
        }
        
        
        // when
        let params = UpdateCategoryAttrParams(uid: "some") |> \.newName .~ "new name"
        self.repository.updateCategory(by: params)
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
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
