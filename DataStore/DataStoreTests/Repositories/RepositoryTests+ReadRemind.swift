//
//  RepositoryTests+ReadRemind.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/10/23.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit

import DataStore


class RepositoryTests_ReadRemind: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var mockRemote: MockRemote!
    var mockLocal: MockLocal!
    var dummyRepository: DummyRepository!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.mockRemote = .init()
        self.mockLocal = .init()
        self.dummyRepository = .init(remote: self.mockRemote, local: self.mockLocal)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.mockRemote = nil
        self.mockLocal = nil
        self.dummyRepository = nil
    }
}


// MARK: - signout case

extension RepositoryTests_ReadRemind {
    
    func testRepo_loadReadRemindsWithoutSignIn() {
        // given
        let expect = expectation(description: "로그아웃한 상태로 리마인드 로드")
        self.mockLocal.register(key: "fetchReadReminds") { Maybe<[ReadRemind]>.just([.dummy(0)]) }
        
        // when
        let loading = self.dummyRepository.requestLoadReadReminds(for: ["i:0"])
        let remindsLists = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(remindsLists.map { $0.count }, [1])
    }
    
    func testRepo_whenLoadReadRemindWithoutSignIn_ignoreLocalError() {
        // given
        let expect = expectation(description: "로그아웃한 상태로 리마인드 로드시에 로컬에러는 무시하고 빈값 반환")
        self.mockLocal.register(key: "fetchReadReminds") { Maybe<[ReadRemind]>.error(LocalErrors.notExists) }
        
        // when
        let loading = self.dummyRepository.requestLoadReadReminds(for: ["i:0"])
        let remindsLists = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(remindsLists.map { $0.count }, [0])
    }
    
    func testRepo_updateReadRemindWithoutSignIn() {
        // given
        let expect = expectation(description: "로그아웃상태에서 로컬캐시 업데이트")
        self.mockLocal.register(key: "updateReadRemind") { Maybe<Void>.just() }
        
        // when
        let updating = self.dummyRepository.requestScheduleReadRemind(.dummy(0))
        let result: Void? = self.waitFirstElement(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepo_whenUpdateReadRemindFailWithoutSignIn() {
        // given
        let expect = expectation(description: "로그아웃상태에서 로컬캐시 업데이트 실패")
        self.mockLocal.register(key: "updateReadRemind") { Maybe<Void>.error(LocalErrors.notExists) }
        
        // when
        let updating = self.dummyRepository.requestScheduleReadRemind(.dummy(0))
        let error = self.waitError(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(error)
    }
    
    func testRepo_cancelRemindWithoutSignIn() {
        // given
        let expect = expectation(description: "로그아웃강태에서 로컬태시 삭제")
        self.mockLocal.register(key: "removeReadRemind") { Maybe<Void>.just() }
        
        // when
        let removing = self.dummyRepository.requestCancelReadRemind(for: "some")
        let result: Void? = self.waitFirstElement(expect, for: removing.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepo_whenCancelRemindWithoutSignInFail() {
        // given
        let expect = expectation(description: "로그아웃강태에서 로컬태시 삭제 실패")
        self.mockLocal.register(key: "removeReadRemind") { Maybe<Void>.error(LocalErrors.notExists) }
        
        // when
        let removing = self.dummyRepository.requestCancelReadRemind(for: "some")
        let error = self.waitError(expect, for: removing.asObservable())
        
        // then
        XCTAssertNotNil(error)
    }
}


// MARK: - signin case

extension RepositoryTests_ReadRemind {
    
    func testRepo_loadReadRemindsWithSignIn() {
        // given
        let expect = expectation(description: "로그인 상태로 리마인드 로드")
        expect.expectedFulfillmentCount = 2
        self.mockLocal.register(key: "fetchReadReminds") { Maybe<[ReadRemind]>.just([.dummy(0)]) }
        self.mockRemote.register(key: "requestLoadReminds") { Maybe<[ReadRemind]>.just([.dummy(0), .dummy(1)]) }
        
        // when
        let loading = self.dummyRepository.requestLoadReadReminds(for: ["i:0", "i:1"])
        let remindsLists = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(remindsLists.map { $0.count }, [1, 2])
    }
    
    func testRepo_whenLoadReadRemindWithSignIn_ignoreLocalError() {
        // given
        let expect = expectation(description: "로그인 상태로 리마인드 로드시에 로컬에러는 무시하고 리모트값만 반환")
        expect.expectedFulfillmentCount = 2
        self.mockLocal.register(key: "fetchReadReminds") { Maybe<[ReadRemind]>.error(LocalErrors.notExists) }
        self.mockRemote.register(key: "requestLoadReminds") { Maybe<[ReadRemind]>.just([.dummy(0), .dummy(1)]) }
        
        // when
        let loading = self.dummyRepository.requestLoadReadReminds(for: ["i:0"])
        let remindsLists = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(remindsLists.map { $0.count }, [0, 2])
    }
    
    func testRepo_whenLoadReadRemindWithSignInFail() {
        // given
        let expect = expectation(description: "로그인 상태로 리마인드 로드시에 실패한 케이스")
        self.mockLocal.register(key: "fetchReadReminds") { Maybe<[ReadRemind]>.just([.dummy(0)]) }
        self.mockRemote.register(key: "requestLoadReminds") { Maybe<[ReadRemind]>.error(RemoteErrors.invalidRequest(nil)) }
        
        // when
        let loading = self.dummyRepository.requestLoadReadReminds(for: ["i:0"])
        let error = self.waitError(expect, for: loading)
        
        // then
        XCTAssertNotNil(error)
    }
    
    func testRepo_updateReadRemindWithSignIn() {
        // given
        let expect = expectation(description: "로그인 상태에서 리마인드 업데이트")
        self.mockLocal.register(key: "updateReadRemind") { Maybe<Void>.just() }
        self.mockRemote.register(key: "requestUpdateReimnd") { Maybe<Void>.just() }
        
        // when
        let updating = self.dummyRepository.requestScheduleReadRemind(.dummy(0))
        let result: Void? = self.waitFirstElement(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepo_whenUpdateReadRemindFailAtLocalWithSignIn_ignore() {
        // given
        let expect = expectation(description: "로그인 상태에서 리마인드 업데이트시 로컬 실패는 무시")
        self.mockLocal.register(key: "updateReadRemind") { Maybe<Void>.error(LocalErrors.notExists) }
        self.mockRemote.register(key: "requestUpdateReimnd") { Maybe<Void>.just() }
        
        // when
        let updating = self.dummyRepository.requestScheduleReadRemind(.dummy(0))
        let result: Void? = self.waitFirstElement(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepo_whenUpdateReadRemindFailWithSignIn() {
        // given
        let expect = expectation(description: "로그인 상태에서 리마인드 업데이트 실패")
        self.mockLocal.register(key: "updateReadRemind") { Maybe<Void>.just() }
        self.mockRemote.register(key: "requestUpdateReimnd") { Maybe<Void>.error(RemoteErrors.invalidRequest(nil)) }
        
        // when
        let updating = self.dummyRepository.requestScheduleReadRemind(.dummy(0))
        let error = self.waitError(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(error)
    }
    
    func testRepo_cancelRemindWithSignIn() {
        // given
        let expect = expectation(description: "로그인 상태에서 리마인드 취소")
        self.mockLocal.register(key: "removeReadRemind") { Maybe<Void>.just() }
        self.mockRemote.register(key: "requestRemoveRemind") { Maybe<Void>.just() }
        
        // when
        let removing = self.dummyRepository.requestCancelReadRemind(for: "some")
        let result: Void? = self.waitFirstElement(expect, for: removing.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepo_whenCancelRemindWithSignInFailAtLocal_ignore() {
        // given
        let expect = expectation(description: "로그인 상태에서 리마인드 취소 로컬 실패시 무시")
        self.mockLocal.register(key: "removeReadRemind") { Maybe<Void>.error(LocalErrors.notExists) }
        self.mockRemote.register(key: "requestRemoveRemind") { Maybe<Void>.just() }
        
        // when
        let removing = self.dummyRepository.requestCancelReadRemind(for: "some")
        let result: Void? = self.waitFirstElement(expect, for: removing.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepo_whenCancelRemindWithSignInFail() {
        // given
        let expect = expectation(description: "로그인 상태에서 리마인드 취소 로컬 실패")
        self.mockLocal.register(key: "removeReadRemind") { Maybe<Void>.just() }
        self.mockRemote.register(key: "requestRemoveRemind") { Maybe<Void>.error(RemoteErrors.invalidRequest(nil)) }
        
        // when
        let removing = self.dummyRepository.requestCancelReadRemind(for: "some")
        let error = self.waitError(expect, for: removing.asObservable())
        
        // then
        XCTAssertNotNil(error)
    }
}

extension RepositoryTests_ReadRemind {
    
    class DummyRepository: ReadRemindRepository, ReadRemidRepositoryDefImpleDependency {
        
        let disposeBag: DisposeBag = .init()
        let remindRemote: ReadRemindRemote
        let remindLocal: ReadRemindLocalStorage
        
        init(remote: ReadRemindRemote, local: ReadRemindLocalStorage) {
            self.remindRemote = remote
            self.remindLocal = local
        }
    }
}
