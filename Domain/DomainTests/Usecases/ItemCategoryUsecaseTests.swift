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
                             remote: [ItemCategory] = (0..<10).map { .dummy($0) }) -> ReadItemCategoryUsecase {
        
        let scenario = StubItemCategoryRepository.Scenario()
            |> \.localCategories .~ .success(local)
            |> \.remoteCategories .~ .success(remote)
            
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
