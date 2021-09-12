//
//  ReadItemUsecaseTests.swift
//  DomainTests
//
//  Created by sudo.park on 2021/09/13.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import UnitTestHelpKit

import Domain

class ReadItemUsecaseTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
    }
    
    private func authProvider(_ signedIn: Bool = true) -> AuthInfoProvider {
        let sharedStore = SharedDataStoreServiceImple()
        let auth = Auth(userID: "uid")
        sharedStore.updateAuth(auth)
        if signedIn {
            let member = Member(uid: auth.userID, nickName: "n", icon: nil)
            sharedStore.save(Member.self, key: SharedDataKeys.currentMember, member)
        }
        return sharedStore
    }
    
    private func makeUsecase(signedIn: Bool = true,
                             shouldfailLoadMyCollections: Bool = false,
                             shouldFailLoadCollection: Bool = false) -> ReadItemLoadUsecase & ReadItemUpdateUsecase {
        
        var repositoryScenario = StubReadItemRepository.Scenario()
        shouldfailLoadMyCollections.then {
            repositoryScenario.myItems = .failure(ApplicationErrors.invalid)
        }
        shouldFailLoadCollection.then {
            repositoryScenario.collection = .failure(ApplicationErrors.invalid)
        }
        
        let repositoryStub = StubReadItemRepository(scenario: repositoryScenario)
        
        return ReadItemUsecaseImple(readItemRepository: repositoryStub,
                                    authInfoProvider: self.authProvider(signedIn))
    }
}


// MARK: - tests load

extension ReadItemUsecaseTests {
    
    func testUsecase_loadMyItemsWithoutSignedIn() {
        // given
        let expect = expectation(description: "로그아웃상태에서 내 아이템 조회")
        let usecase = self.makeUsecase(signedIn: false)
        
        // when
        let items = self.waitFirstElement(expect, for: usecase.loadMyItems())
        
        // then
        XCTAssertEqual(items?.count, 11)
    }
    
    func testUsecase_loadMyItemsFailWithoutSignedIn() {
        // given
        let expect = expectation(description: "로그아웃 상태에서 내 아이켐 조회 실패")
        let usecase = self.makeUsecase(signedIn: false, shouldfailLoadMyCollections: true)
        
        // when
        let error = self.waitError(expect, for: usecase.loadMyItems())
        
        // then
        XCTAssertNotNil(error)
    }
    
    func testUsecase_loadMyItemsWithSignedIn() {
        // given
        let expect = expectation(description: "로그인 상태에서 내 아이템 조회")
        let usecase = self.makeUsecase(signedIn: true)
        
        // when
        let items = self.waitFirstElement(expect, for: usecase.loadMyItems())
        
        // then
        XCTAssertEqual(items?.count, 11)
    }
    
    func testUsecase_loadMyItemsFailWithSignedIn() {
        // given
        let expect = expectation(description: "로그인 상태에서 내 아이템 조회 실패")
        let usecase = self.makeUsecase(signedIn: true,
                                       shouldfailLoadMyCollections: true)
        
        // when
        let error = self.waitError(expect, for: usecase.loadMyItems())
        
        // then
        XCTAssertNotNil(error)
    }
    
    func testUsecase_loadCollectionWithoutSignedIn() {
        // given
        let expect = expectation(description: "로그아웃상태에서 콜렉션 로드")
        let usecase = self.makeUsecase(signedIn: false)
        
        // when
        let items = self.waitFirstElement(expect, for: usecase.loadCollectionItems("some"))
        
        // then
        XCTAssertNotNil(items)
    }
    
    // load collection + 로그아웃 상태 -> 캐시에 저장된거 불러몸, 없으면 에러
    func testUsecase_loadCollectionItemsFailWithoutSignedIn() {
        // given
        let expect = expectation(description: "로그아웃상태에서 콜렉션 로드 실패")
        let usecase = self.makeUsecase(signedIn: false, shouldFailLoadCollection: true)
        
        // when
        let error = self.waitError(expect, for: usecase.loadCollectionItems("some"))
        
        // then
        XCTAssertNotNil(error)
    }
    
    // load collection + 로그인 상태 -> 캐시에 저장된거 + 리모트에서 불러옴
    func testUsecase_loadCollectionWithSignedIn() {
        // given
        let expect = expectation(description: "로그인 상태에서 콜렉션 로드")
        let usecase = self.makeUsecase(signedIn: true)
        
        // when
        let items = self.waitFirstElement(expect, for: usecase.loadCollectionItems("some"))
        
        // then
        XCTAssertEqual(items?.count, 2)
    }
    
    // load collection + 로그인 상태 -> 캐시와 리모트에 둘다 없으면 에러
    func testUsecase_loadCollectionFailWithSignedIn() {
        // given
        let expect = expectation(description: "로그인 상태에서 콜렉션 로드시 로컬 로드 실패")
        let usecase = self.makeUsecase(signedIn: true,
                                       shouldFailLoadCollection: true)
        
        // when
        let error = self.waitError(expect, for: usecase.loadCollectionItems("some"))
        
        // then
        XCTAssertNotNil(error)
    }
}
