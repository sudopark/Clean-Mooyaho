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
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
    }
    
    private func makeUsecase(isSignIn: Bool = false,
                             local: [ItemCategory] = (0..<10).map{ .dummy($0) },
                             remote: [ItemCategory] = (0..<10).map { .dummy($0) }) -> ReadItemCategoryUsecase {
        
        let scenario = StubItemCategoryRepository.Scenario()
            |> \.localCategories .~ .success(local)
            |> \.remoteCategories .~ .success(remote)
            
        let stubRepositroy = StubItemCategoryRepository(scenario: scenario)
        let sharedStore = SharedDataStoreServiceImple()
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
}
