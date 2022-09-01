//
//  SwitchLoadingTests.swift
//  DomainTests
//
//  Created by sudo.park on 2022/09/01.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift
import RxSwiftDoNotation

import Domain
import UnitTestHelpKit


class SwitchLoadingTests: BaseTestCase {
    
    private var spyLocal: StubLocal!
    private var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        self.spyLocal = .init()
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.spyLocal = nil
        self.disposeBag = nil
    }
    
    private func switchLoading(isSignIn: Bool) async throws -> [Int] {
        let auth: Auth? = isSignIn ? Auth(userID: "some") : nil
        let provider = AuthInfoProviderImple(auth: auth)
        let switchLoading = SwitchLoading(provider, self.spyLocal!, StubRemote())
        return try await switchLoading
            .do { remote, _ in
                return try await remote.load()
            } andUpdateCache: { local, intsFromRemote in
                try await local.update(intsFromRemote)
            } orLoadFromLocal: { local in
                return try await local.load()
            }
    }
}


extension SwitchLoadingTests {
    
    func testSwitchLoading_whenSignout_loadFromLocal() async {
        // given
        // when
        let ints = try? await self.switchLoading(isSignIn: false)
        
        // then
        XCTAssertEqual(ints, [0, 1, 2])
    }
    
    func testSwitchLoading_whenSignIn_loadFromRemote() async {
        // given
        // when
        let ints = try? await self.switchLoading(isSignIn: true)
        
        // then
        XCTAssertEqual(ints, [-1, -2, -3])
    }
    
    func testSwitchLoading_whenSignInAndLoadFromRemote_updateLocal() {
        // given
        let expect = expectation(description: "로그인 상태에서 switch loading 시에 리모트에서 로드해서 로컬 업데이트")
        var updatedInts: [Int]?
        self.spyLocal.didUpdatedInts = {
            updatedInts = $0
            expect.fulfill()
        }
        
        // when
        let load = Observable<[Int]>.create { try await self.switchLoading(isSignIn: true) }
        load.subscribe().disposed(by: self.disposeBag)
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(updatedInts, [-1, -2, -3])
    }
}


private extension SwitchLoadingTests {
    
    class StubLocal {
        
        func load() async throws -> [Int] {
            return [0, 1, 2]
        }
        
        var didUpdatedInts: (([Int]) -> Void)?
        func update(_ ints: [Int]) async throws {
            self.didUpdatedInts?(ints)
        }
    }
    
    class StubRemote {
        func load() async throws -> [Int] {
            return [-1, -2, -3]
        }
    }
}
