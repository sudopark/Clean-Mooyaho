//
//  LoadWithCacheTests.swift
//  DomainTests
//
//  Created by sudo.park on 2022/09/01.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift
import RxSwiftDoNotation
import UnitTestHelpKit

import Domain


class LoadWithCacheTests: BaseTestCase {
    
    private var disposeBag: DisposeBag!
    private var spyLocal: StubLocal!
    
    override func setUpWithError() throws {
        self.spyLocal = .init()
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.spyLocal = nil
        self.disposeBag = nil
    }
    
    private func loadingWithCache(isSignIn: Bool) async throws -> [Int] {
        let auth: Auth? = isSignIn ? Auth(userID: "some") : nil
        let provider = AuthInfoProviderImple(auth: auth)
        let loadWithCache = LoadWithCache(provider, self.spyLocal!, StubRemote())
        let ids = [0, 1, 2, 3, 4, 5]
        return try await loadWithCache
            .do { local in
                try await local.load(ids: ids)
            } thenLoadFromRemote: { remote, _, idsFromLocal in
                let loadNeedIDs = ids.filter { id in !idsFromLocal.contains(id) }
                return try await remote.load(ids: loadNeedIDs)
            } andUpdateLocal: { local, intsFromRemote in
                try await local.update(intsFromRemote)
            }
    }
}


extension LoadWithCacheTests {
    
    func testLoadWithCache_whenSignout_loadFromLocal() async {
        // given
        // when
        let ints = try? await self.loadingWithCache(isSignIn: false)
        
        // then
        XCTAssertEqual(ints, [0, 1, 2])
    }
    
    func testLoadWithCache_whenSignIn_loadFromRemoteIfNotExistsOnLocal() async {
        // given
        // when
        let ints = try? await self.loadingWithCache(isSignIn: true)
        
        // then
        XCTAssertEqual(ints, [0, 1, 2, 3, 4, 5])
    }
    
    func testLoadWithCache_whenSignInAndLoadFromRemote_updateLocal() {
        // given
        let expect = expectation(description: "로그인상태에서 리모트에서 조회해온 데이터는 로컬 업데이트")
        var updatedInts: [Int]?
        self.spyLocal.didUpdatedInts = {
            updatedInts = $0
            expect.fulfill()
        }
        
        // when
        let load = Observable<[Int]>.create { try await self.loadingWithCache(isSignIn: true) }
        load.subscribe().disposed(by: self.disposeBag)
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(updatedInts, [3, 4, 5])
    }
}


private extension LoadWithCacheTests {
    
    class StubLocal {
        
        func load(ids: [Int]) async throws -> [Int] {
            return ids.filter { $0 < 3 }
        }
        
        var didUpdatedInts: (([Int]) -> Void)?
        func update(_ ints: [Int]) async throws {
            self.didUpdatedInts?(ints)
        }
    }
    
    class StubRemote {
        
        func load(ids: [Int]) async throws -> [Int] {
            return ids
        }
    }
}
