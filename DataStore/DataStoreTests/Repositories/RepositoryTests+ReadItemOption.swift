//
//  RepositoryTests+ReadItemOption.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/10/13.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit

import DataStore


class RepositoryTests_ReadItemOption: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var mockRemote: MockRemote!
    var mockLocal: MockLocal!
    var dummyRepository: DummyRepository!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.mockLocal = .init()
        self.mockRemote = .init()
        self.dummyRepository = .init(local: self.mockLocal, remote: self.mockRemote)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.mockLocal = nil
        self.mockRemote = nil
        self.dummyRepository = nil
    }
}

extension RepositoryTests_ReadItemOption {
    
    func testRepository_fetchLatestIsShrinkMode() {
        // given
        let expect = expectation(description: "마지막 사용한 접기모드 로드")
        
        self.mockLocal.register(key: "fetchReadItemIsShrinkMode") { Maybe<Bool?>.just(true) }
        
        // when
        let load = self.dummyRepository.fetchLastestsIsShrinkModeOn()
        let flag = self.waitFirstElement(expect, for: load.asObservable())
        
        // then
        XCTAssertEqual(flag, true)
    }
    
    func testRepository_updateLatestIsShrinkMode() {
        // given
        let expect = expectation(description: "마지막으로 사용한 접기모드여부 저장")
        
        self.mockLocal.register(key: "updateReadItemIsShrinkMode") { Maybe<Void>.just() }
        
        // when
        let update = self.dummyRepository.updateLatestIsShrinkModeOn(true)
        let result: Void? = self.waitFirstElement(expect, for: update.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepository_fetchLatestSortOption() {
        // given
        let expect = expectation(description: "마지막 사용한 정렬옵션 로드")
        
        self.mockLocal.register(key: "fetchLatestReadItemSortOrder") { Maybe<ReadCollectionItemSortOrder?>.just(.byCustomOrder) }
        
        // when
        let load = self.dummyRepository.fetchLatestSortOrder()
        let option = self.waitFirstElement(expect, for: load.asObservable())
        
        // then
        XCTAssertEqual(option, .byCustomOrder)
    }
    
    func testRepository_updateLatestSortOption() {
        // given
        let expect = expectation(description: "마지막으로 사용한 정렬옵션 저장")
        
        self.mockLocal.register(key: "updateLatestReadItemSortOrder") { Maybe<Void>.just() }
        
        // when
        let update = self.dummyRepository.updateLatestSortOrder(to: .byCustomOrder)
        let result: Void? = self.waitFirstElement(expect, for: update.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
}

extension RepositoryTests_ReadItemOption {
    
    func testRepository_loadCollectionCustomOrderWitoutSignIn() {
        // given
        let expect = expectation(description: "로그아웃상태에서 커스텀 오더 로드")
        self.mockLocal.register(key: "fetchReadItemCustomOrder") { Maybe<[String]?>.just(["some"])}
        
        // when
        let loading = self.dummyRepository.requestLoadCustomOrder(for: "c:1")
        let orders = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(orders, [["some"]])
    }
    
    func testRepository_updateCollectionCustomOrderWithoutSignIn() {
        // given
        let expect = expectation(description: "로그아웃 상태에서 커스텀 오더 업데이트")
        self.mockLocal.register(key: "updateReadItemCustomOrder") { Maybe<Void>.just() }
        
        // when
        let updating = self.dummyRepository.requestUpdateCustomSortOrder(for: "c:1", itemIDs: ["some"])
        let result: Void? = self.waitFirstElement(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepository_updateFailCollectionCustomOrderWithoutSignIn() {
        // given
        let expect = expectation(description: "로그아웃 상태에서 커스텀오더 저장 실패")
        self.mockLocal.register(key: "updateReadItemCustomOrder") { Maybe<Void>.error(ApplicationErrors.invalid) }
        
        // when
        let updating = self.dummyRepository.requestUpdateCustomSortOrder(for: "c:1", itemIDs: ["some"])
        let error = self.waitError(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(error)
    }
    
    func testRepository_loadCollectionCustomOrderWithSignIn() {
        // given
        let expect = expectation(description: "로그인 상태에서 커스텀 오더 로드")
        expect.expectedFulfillmentCount = 2
        self.mockRemote.signInMemberID = "some"
        self.mockLocal.register(key: "fetchReadItemCustomOrder") { Maybe<[String]?>.just(["some"])}
        self.mockRemote.register(key: "requestLoadReadItemCustomOrder") { Maybe<[String]?>.just(["some", "e"])}
        
        // when
        let loading = self.dummyRepository.requestLoadCustomOrder(for: "c:1")
        let orders = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(orders, [["some"], ["some", "e"]])
    }
    
    func testRepository_loadCollectionCustomOrderWithSignIn_onlyLocalExists() {
        // given
        let expect = expectation(description: "로그인 상태에서 커스텀 오더 로드 - 로컬에만 데이터 존재하는 경우")
        self.mockRemote.signInMemberID = "some"
        self.mockLocal.register(key: "fetchReadItemCustomOrder") { Maybe<[String]?>.just(["some"])}
        self.mockRemote.register(key: "requestLoadReadItemCustomOrder") { Maybe<[String]?>.just(nil)}
        
        // when
        let loading = self.dummyRepository.requestLoadCustomOrder(for: "c:1")
        let orders = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(orders, [["some"]])
    }
    
    func testRepository_loadCollectionCustomOrderWithSignIn_onlyRemoteExists() {
        // given
        let expect = expectation(description: "로그인 상태에서 커스텀 오더 로드 - 리모트에만 데이터 존재하는 경우")
        self.mockRemote.signInMemberID = "some"
        self.mockLocal.register(key: "fetchReadItemCustomOrder") { Maybe<[String]?>.just(nil)}
        self.mockRemote.register(key: "requestLoadReadItemCustomOrder") { Maybe<[String]?>.just(["some", "e"])}
        
        // when
        let loading = self.dummyRepository.requestLoadCustomOrder(for: "c:1")
        let orders = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(orders, [["some", "e"]])
    }
    
    func testRepository_updateCollectionCustomOrderWithSignIn() {
        // given
        let expect = expectation(description: "로그인 상태에서 커스텀 정렬 옵션 업데이트")
        self.mockRemote.signInMemberID = "some"
        self.mockRemote.register(key: "requestUpdateReadItemCustomOrder") { Maybe<Void>.just() }
        self.mockLocal.register(key: "updateReadItemCustomOrder") { Maybe<Void>.just() }
        
        let updating = self.dummyRepository.requestUpdateCustomSortOrder(for: "c:1", itemIDs: ["some"])
        let result: Void? = self.waitFirstElement(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepository_whenFailToUpdateCustomOrderAtLocalWithSignIn_ignore() {
        // given
        let expect = expectation(description: "로그인 상태에서 커스텀 정렬 옵션 업데이트시 로컬에러는 무시")
        self.mockRemote.signInMemberID = "some"
        self.mockRemote.register(key: "requestUpdateReadItemCustomOrder") { Maybe<Void>.just() }
        self.mockLocal.register(key: "updateReadItemCustomOrder") { Maybe<Void>.error(ApplicationErrors.invalid) }
        
        let updating = self.dummyRepository.requestUpdateCustomSortOrder(for: "c:1", itemIDs: ["some"])
        let result: Void? = self.waitFirstElement(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepository_failtoUpdateCollectionCustomOrder() {
        // given
        let expect = expectation(description: "로그인 상태에서 커스텀 정렬 옵션 업데이트 실패")
        self.mockRemote.signInMemberID = "some"
        self.mockRemote.register(key: "requestUpdateReadItemCustomOrder") { Maybe<Void>.error(ApplicationErrors.invalid) }
        self.mockLocal.register(key: "updateReadItemCustomOrder") { Maybe<Void>.just() }
        
        let updating = self.dummyRepository.requestUpdateCustomSortOrder(for: "c:1", itemIDs: ["some"])
        let error = self.waitError(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(error)
    }
}


extension RepositoryTests_ReadItemOption {
    
    class DummyRepository: ReadItemOptionsRepository, ReadItemOptionReposiotryDefImpleDependency {
        
        let disposeBag: DisposeBag = .init()
        let readItemOptionLocal: ReadItemOptionsLocalStorage
        let readItemOptionRemote: ReadItemOptionsRemote
        
        init(local: ReadItemOptionsLocalStorage, remote: ReadItemOptionsRemote) {
            self.readItemOptionRemote = remote
            self.readItemOptionLocal = local
        }
    }
}
