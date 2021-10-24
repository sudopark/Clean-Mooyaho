//
//  RepositoryTests+ReadLinkMemo.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/10/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit

import DataStore


class RepositoryTests_ReadLinkMemo: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var mockLocal: MockLocal!
    var mockRemote: MockRemote!
    var dummyRepository: DummyRepository!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.mockLocal = .init()
        self.mockRemote = .init()
        self.dummyRepository = .init(remote: self.mockRemote, local: self.mockLocal)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.mockLocal = nil
        self.mockRemote = nil
        self.dummyRepository = nil
    }
}

// MARK: - signout case

extension RepositoryTests_ReadLinkMemo {
    
    func testRepository_loadMemoWithoutSignin() {
        // given
        let expect = expectation(description: "로그아웃 상태에서 메모 로드")
        self.mockLocal.register(key: "fetchMemo") { Maybe<ReadLinkMemo?>.just(.init(itemID: "some"))}
        
        // when
        let loading = self.dummyRepository.requestLoadMemo(for: "some")
        let memos = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(memos.count, 1)
    }
    
    func testRepository_loadMemoWithoutSignin_fail_resultIsNil() {
        // given
        let expect = expectation(description: "로그아웃 상태에서 메모 로드 실패")
        self.mockLocal.register(key: "fetchMemo") { Maybe<ReadLinkMemo?>.error(ApplicationErrors.invalid) }
        
        // when
        let loading = self.dummyRepository.requestLoadMemo(for: "some")
        let memo = self.waitFirstElement(expect, for: loading)
        
        // then
        XCTAssertNil(memo)
    }
    
    func testRepository_updateMemoWithoutSignin() {
        // given
        let expect = expectation(description: "로그아웃 상태에서 메모 업데이트")
        self.mockLocal.register(key: "updateMemo") { Maybe<Void>.just() }
        
        // when
        let updating = self.dummyRepository.requestUpdateMemo(.init(itemID: "some"))
        let result: Void? = self.waitFirstElement(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepository_updateMemoWithoutSignin_fail() {
        // given
        let expect = expectation(description: "로그아웃 상태에서 메모 업데이트 실패")
        self.mockLocal.register(key: "updateMemo") { Maybe<Void>.error(ApplicationErrors.invalid) }
        
        // when
        let updating = self.dummyRepository.requestUpdateMemo(.init(itemID: "some"))
        let error = self.waitError(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(error)
    }
    
    func testRepository_deleleteMemoWithoutSignin() {
        // given
        let expect = expectation(description: "로그아웃 상태에서 메모 삭제")
        self.mockLocal.register(key: "deleteMemo") { Maybe<Void>.just() }
        
        // when
        let deleting = self.dummyRepository.requestRemoveMemo(for: "some")
        let result: Void? = self.waitFirstElement(expect, for: deleting.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepository_deleleteMemoWithoutSignin_fail() {
        // given
        let expect = expectation(description: "로그아웃 상태에서 메모 삭제 실패")
        self.mockLocal.register(key: "deleteMemo") { Maybe<Void>.error(ApplicationErrors.invalid) }
        
        // when
        let deleting = self.dummyRepository.requestRemoveMemo(for: "some")
        let error = self.waitError(expect, for: deleting.asObservable())
        
        // then
        XCTAssertNotNil(error)
    }
}


// MARK: - signin case

extension RepositoryTests_ReadLinkMemo {
    
    func testRepository_loadMemoWithSignin() {
        // given
        let expect = expectation(description: "로그인 상태에서 메모 로드")
        expect.expectedFulfillmentCount = 2
        self.mockLocal.register(key: "fetchMemo") { Maybe<ReadLinkMemo?>.just(.init(itemID: "some"))}
        self.mockRemote.register(key: "requestLoadMemo") { Maybe<ReadLinkMemo?>.just(.init(itemID: "some"))}
        
        // when
        let loading = self.dummyRepository.requestLoadMemo(for: "some")
        let memos = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(memos.count, 2)
    }
    
    func testRepository_loadMemoWithSigninAndLocalFail_ignore() {
        // given
        let expect = expectation(description: "로그인 상태에서 메모 로드")
        expect.expectedFulfillmentCount = 2
        self.mockLocal.register(key: "fetchMemo") { Maybe<ReadLinkMemo?>.error(ApplicationErrors.invalid) }
        self.mockRemote.register(key: "requestLoadMemo") { Maybe<ReadLinkMemo?>.just(.init(itemID: "some"))}
        
        // when
        let loading = self.dummyRepository.requestLoadMemo(for: "some")
        let memos = self.waitElements(expect, for: loading)
        
        // then
        let isNills = memos.map { $0 == nil }
        XCTAssertEqual(isNills, [true, false])
    }
    
    func testRepository_loadMemoWithSignin_fail() {
        // given
        let expect = expectation(description: "로그인 상태에서 메모 로드 실패")
        self.mockLocal.register(key: "fetchMemo") { Maybe<ReadLinkMemo?>.just(.init(itemID: "some"))}
        self.mockRemote.register(key: "requestLoadMemo") { Maybe<ReadLinkMemo?>.error(ApplicationErrors.invalid) }
        
        // when
        let loading = self.dummyRepository.requestLoadMemo(for: "some")
        let error = self.waitError(expect, for: loading)
        
        // then
        XCTAssertNotNil(error)
    }
    
    func testRepository_updateMemoWithSignin() {
        // given
        let expect = expectation(description: "로그인 상태에서 메모 업데이트")
        self.mockLocal.register(key: "updateMemo") { Maybe<Void>.just() }
        self.mockRemote.register(key: "requestUpdateMemo") { Maybe<Void>.just() }
        
        // when
        let updating = self.dummyRepository.requestUpdateMemo(.init(itemID: "some"))
        let result: Void? = self.waitFirstElement(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepository_updateMemoWithSignin_ignoreLocalError() {
        // given
        let expect = expectation(description: "로그인 상태에서 메모 업데이트 로컬 실패는 무시")
        self.mockLocal.register(key: "updateMemo") { Maybe<Void>.error(ApplicationErrors.invalid) }
        self.mockRemote.register(key: "requestUpdateMemo") { Maybe<Void>.just() }
        
        // when
        let updating = self.dummyRepository.requestUpdateMemo(.init(itemID: "some"))
        let result: Void? = self.waitFirstElement(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepository_updateMemoWithSignin_fail() {
        // given
        let expect = expectation(description: "로그인 상태에서 메모 업데이트 실패")
        self.mockLocal.register(key: "updateMemo") { Maybe<Void>.just() }
        self.mockRemote.register(key: "requestUpdateMemo") { Maybe<Void>.error(ApplicationErrors.invalid) }
        
        // when
        let updating = self.dummyRepository.requestUpdateMemo(.init(itemID: "some"))
        let error = self.waitError(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(error)
    }
    
    func testRepository_deleleteMemoWithSignin() {
        // given
        let expect = expectation(description: "로그인 상태에서 메모 삭제")
        self.mockLocal.register(key: "deleteMemo") { Maybe<Void>.just() }
        self.mockRemote.register(key: "requestDeleteMemo") { Maybe<Void>.just() }
        
        // when
        let removing = self.dummyRepository.requestRemoveMemo(for: "some")
        let result: Void? = self.waitFirstElement(expect, for: removing.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepository_deleleteMemoWithSignin_ignoreLocalError() {
        // given
        let expect = expectation(description: "로그인 상태에서 메모 삭제 로컬에러는 무시")
        self.mockLocal.register(key: "deleteMemo") { Maybe<Void>.error(ApplicationErrors.invalid) }
        self.mockRemote.register(key: "requestDeleteMemo") { Maybe<Void>.just() }
        
        // when
        let removing = self.dummyRepository.requestRemoveMemo(for: "some")
        let result: Void? = self.waitFirstElement(expect, for: removing.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepository_deleleteMemoWithSignin_fail() {
        // given
        let expect = expectation(description: "로그인 상태에서 메모 삭제 실패")
        self.mockLocal.register(key: "deleteMemo") { Maybe<Void>.just() }
        self.mockRemote.register(key: "requestDeleteMemo") { Maybe<Void>.error(ApplicationErrors.invalid) }
        
        // when
        let removing = self.dummyRepository.requestRemoveMemo(for: "some")
        let error = self.waitError(expect, for: removing.asObservable())
        
        // then
        XCTAssertNotNil(error)
    }
}


extension RepositoryTests_ReadLinkMemo {
    
    class DummyRepository: ReadLinkMemoRepository, ReadLinkMemoRepositoryDefImpleDependency {
        
        let disposeBag: DisposeBag = .init()
        let memoRemote: ReadLinkMemoRemote
        let memoLocal: ReadLinkMemoLocalStorage
        init(remote: ReadLinkMemoRemote, local: ReadLinkMemoLocalStorage) {
            self.memoRemote = remote
            self.memoLocal = local
        }
    }
}
