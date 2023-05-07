//
//  ConcatLoadingTests.swift
//  DomainTests
//
//  Created by sudo.park on 2022/08/31.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit


class ConcatLoadingTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    private var spyLocal: StubLocal!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.spyLocal = nil
    }
    
    private func makeConcatLoad(
        isSignIn: Bool,
        withRefreshCache: Bool = true
    ) -> Observable<[Int]> {
        let auth: Auth? = isSignIn ? .init(userID: "some") : nil
        let provider = AuthInfoProviderImple(auth: auth)
        let (local, remote) = (StubLocal(), StubRemote())
        self.spyLocal = local
        
        let loading = ConcatLoading(provider, local, remote)
        
        guard withRefreshCache else {
            return loading
                .do { local in
                    try await local.load()
                } thenRemoteIfNeed: { remote, _ in
                    try await remote.load()
                }
        }

        return loading
            .do { local in
                return try await local.load()
            } thenRemoteIfNeed: { remote, _ in
                return try await remote.load()
            } andRefreshCache: { local, newInts in
                return try await local.update(newInts)
            }
    }
}

extension ConcatLoadingTests {
    
    func testConcatLoading_whenSignout_loadOnlyFromLocal() {
        // given
        let expect = expectation(description: "로그아웃일때는 로컬서만 로드")
        let loading = self.makeConcatLoad(isSignIn: false)
        
        // when
        let intLists = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(intLists, [
            [1, 2, 3]
        ])
    }
    
    func testConcatLoading_whenSignIn_loadBothLocalAndRemote() {
        // given
        let expect = expectation(description: "로그인일때는 로컬에서 먼저 로드하고 리모트에서 로드")
        expect.expectedFulfillmentCount = 2
        let loading = self.makeConcatLoad(isSignIn: true)
        
        // when
        let intLists = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(intLists, [
            [1, 2, 3],
            [4, 5, 6]
        ])
    }
    
    func testConcatLoading_whenSignIn_updateLocalByRemoteData() {
        // given
        let expect = expectation(description: "리모트에서 로드한 경우에는 캐시 업데이트")
        let loading = self.makeConcatLoad(isSignIn: true)
        var updated: [Int]?
        self.spyLocal.didUpdateCalled = { ints in
            updated = ints
            expect.fulfill()
        }
        
        // when
        loading
            .subscribe()
            .disposed(by: self.disposeBag)
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(updated, [4, 5 ,6])
    }
    
    func testConcatLoading_whenSignInAndUpdateCacheNotNeed_doNotRefreshCache() {
        // given
        let expect = expectation(description: "리모트에서 로드한 경우에는 캐시 업데이트")
        expect.isInverted = true
        let loading = self.makeConcatLoad(isSignIn: true, withRefreshCache: false)
        var updated: [Int]?
        self.spyLocal.didUpdateCalled = { ints in
            updated = ints
            expect.fulfill()
        }
        
        // when
        loading
            .subscribe()
            .disposed(by: self.disposeBag)
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(updated, nil)
    }
}


private extension ConcatLoadingTests {
    
    class StubLocal {
        
        func load() async throws -> [Int] {
            return [1, 2, 3]
        }
        
        var didUpdateCalled: (([Int]) -> Void)?
        func update(_ ints: [Int]) async throws {
            self.didUpdateCalled?(ints)
        }
    }
    
    class StubRemote {
        
        func load() async throws -> [Int] {
            return [4, 5, 6]
        }
    }
}
