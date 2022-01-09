//
//  ItemCategoryUsecaseTests.swift
//  DomainTests
//
//  Created by sudo.park on 2021/10/08.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift
import Prelude
import Optics

import UnitTestHelpKit

import Domain


class ItemCategoryUsecaseTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var spyStore: SharedDataStoreService!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.spyStore = nil
    }
    
    private func makeUsecase(isSignIn: Bool = false,
                             local: [ItemCategory] = (0..<10).map{ .dummy($0) },
                             remote: [ItemCategory] = (0..<10).map { .dummy($0) },
                             findingCategory: ItemCategory? = nil) -> ReadItemCategoryUsecase {
        
        let scenario = StubItemCategoryRepository.Scenario()
            |> \.localCategories .~ .success(local)
            |> \.remoteCategories .~ .success(remote)
            |> \.loadWithPagingResult .~ .success(remote)
            |> \.findingCategoryResult .~ .success(findingCategory)
            
        let stubRepositroy = StubItemCategoryRepository(scenario: scenario)
        let sharedStore = SharedDataStoreServiceImple()
        self.spyStore = sharedStore
        
        isSignIn.then {
            sharedStore.updateAuth(Auth(userID: "some"))
            sharedStore.update(Member.self, key: SharedDataKeys.currentMember.rawValue) { _ in
                return Member(uid: "some", nickName: nil, icon: nil)
            }
        }
        return ReadItemCategoryUsecaseImple(repository: stubRepositroy, sharedService: sharedStore)
    }
    
    private var dummyIDs: [String] {
        return (0..<10).map { "cate:\($0)" }
    }
}


extension ItemCategoryUsecaseTests {
    
    func testUsecase_loadItemCategories_withoutSignin() {
        // given
        let expect = expectation(description: "로그인 안한 상태에서 카테고리 조회")
        let usecase = self.makeUsecase(isSignIn: false, local: (0..<10).map { .dummy($0)})
        
        // when
        let categories = self.waitFirstElement(expect, for: usecase.categories(for: self.dummyIDs))
        
        // then
        XCTAssertEqual(categories?.count, 10)
    }
    
    func testUsecase_loadItemCategories_withSignIn() {
        // given
        let expect = expectation(description: "로그인 상태에서 카테고리 조회")
        let usecase = self.makeUsecase(isSignIn: true,
                                       local: (0..<5).map { .dummy($0) },
                                       remote: (5..<10).map { .dummy($0) })
        
        // when
        let categories = self.waitFirstElement(expect, for: usecase.categories(for: self.dummyIDs))
        
        // then
        XCTAssertEqual(categories?.count, 10)
    }
    
    func testUsecase_updatecategories() {
        // given
        let expect = expectation(description: "카테고리 업데이트")
        let usecase = self.makeUsecase()
        
        // when
        let updating = usecase.updateCategories([.dummy(0)])
        let result: Void? = self.waitFirstElement(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testUsecase_makeNewCategory() {
        // given
        let expect = expectation(description: "새로운 카테고리 생성")
        let usecase = self.makeUsecase()
        
        // when
        let making = usecase.makeCategory("new", colorCode: "soem")
        let newCategory = self.waitFirstElement(expect, for: making.asObservable())
        
        // then
        XCTAssertNotNil(newCategory)
    }
    
    func testUsecase_whenAfterUpdateCategories_updateSharedDataStore() {
        // given
        let expect = expectation(description: "카테고리 업데이트 이후에 공유되는 카테고리값 업데이트")
        let usecase = self.makeUsecase()
        
        // when
        let key = SharedDataKeys.categoriesMap.rawValue
        let source = self.spyStore.observeWithCache([String: ItemCategory].self, key: key)
            .compactMap { $0?.values.first(where: { $0.name == "new"} )}
        let newcategory = self.waitFirstElement(expect, for: source) {
            usecase.makeCategory("new", colorCode: "some")
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        // then
        XCTAssertEqual(newcategory?.name, "new")
    }
}


extension ItemCategoryUsecaseTests {
    
    func testUsecase_loadCategoriesWithPaging() {
        // given
        let expect = expectation(description: "카테고리 페이징으로 로드")
        let usecase = self.makeUsecase()
        
        // when
        let loading = usecase.loadCategories(earilerThan: .now())
        let items = self.waitFirstElement(expect, for: loading.asObservable())
        
        // then
        XCTAssertEqual(items?.count, 10)
    }
    
    func testUsecase_whenAfterLoadCategoriesWithPaging_updateStore() {
        // given
        let expect = expectation(description: "카테고리 페이징으로 로드한 이후에 데이터스토어 업데이트")
        let usecase = self.makeUsecase()
        
        // when
        let source = self.spyStore
            .observe([String: ItemCategory].self, key: SharedDataKeys.categoriesMap.rawValue)
        let cateMap = self.waitFirstElement(expect, for: source) {
            usecase.loadCategories(earilerThan: .now())
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        // then
        XCTAssertEqual(cateMap?.count, 10)
    }
    
    func testUsecase_deleteCategory() {
        // given
        let expect = expectation(description: "아이템 카테고리 삭제")
        let usecase = self.makeUsecase()
        
        // when
        let deleting = usecase.deleteCategory("some")
        let result: Void? = self.waitFirstElement(expect, for: deleting.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testUsecase_whenAfterDeleteCategory_updateOnStore() {
        // given
        let expext = expectation(description: "아이템 카테고리 삭제 이후에 스토어 에서도 삭제")
        expext.expectedFulfillmentCount = 2
        
        let usecase = self.makeUsecase()
        let datKey = SharedDataKeys.categoriesMap
        let dummy = ItemCategory.dummy(100); let dummy2 = ItemCategory.dummy(1)
        self.spyStore.save([String: ItemCategory].self, key: datKey, [
            dummy.uid: dummy, dummy2.uid: dummy2
        ])
        
        // when
        let source = self.spyStore.observeWithCache([String: ItemCategory].self, key: datKey.rawValue)
            .compactMap { $0 }
        let cateMaps = self.waitElements(expext, for: source) {
            usecase.deleteCategory(dummy.uid)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        // then
        let firstMap = cateMaps.first
        XCTAssertEqual(firstMap?.count, 2)
        XCTAssertEqual(firstMap?[dummy.uid] != nil, true)
        XCTAssertEqual(firstMap?[dummy2.uid] != nil, true)
        
        let secondMap = cateMaps.last
        XCTAssertEqual(secondMap?.count, 1)
        XCTAssertEqual(secondMap?[dummy.uid] != nil, false)
    }
    
    func testUsecase_whenUpdateCategorySameNameCategoryExistsOnStore_error() {
        // given
        let expect = expectation(description: "카테고리 업데이트시에 스토어에 동일한 이름의 카테고리 존재시 에러")
        let usecase = self.makeUsecase()
        let newCategory = ItemCategory.dummy(0)
        self.spyStore.save([String: ItemCategory].self, key: .categoriesMap, [newCategory.uid: newCategory])
        
        // when
        let params = UpdateCategoryAttrParams(uid: newCategory.uid)
            |> \.newName .~ newCategory.name
        let updating = usecase.updateCategory(by: params, from: newCategory)
        let error = self.waitError(expect, for: updating.asObservable())
        
        // then
        XCTAssertEqual(error is SameNameCategoryExistsError, true)
    }
    
    func testusecase_whenUpdateCategorySameNameCategoryExists_error() {
        // given
        let expect = expectation(description: "카테고리 업데이트시에 동일한 이름의 카테고리 존재시 에러")
        let newCategory = ItemCategory.dummy(0)
        let usecase = self.makeUsecase(findingCategory: newCategory)
        
        // when
        let params = UpdateCategoryAttrParams(uid: newCategory.uid)
            |> \.newName .~ newCategory.name
        let updating = usecase.updateCategory(by: params, from: newCategory)
        let error = self.waitError(expect, for: updating.asObservable())
        
        // then
        XCTAssertEqual(error is SameNameCategoryExistsError, true)
    }
    
    func testUsecase_updateCategory() {
        // given
        let expect = expectation(description: "카테고리 업데이트")
        let newCategory = ItemCategory.dummy(0)
        let usecase = self.makeUsecase(findingCategory: nil)
        
        // when
        let params = UpdateCategoryAttrParams(uid: newCategory.uid)
            |> \.newName .~ newCategory.name
        let updating = usecase.updateCategory(by: params, from: newCategory)
        let updated = self.waitFirstElement(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(updated)
    }
}
