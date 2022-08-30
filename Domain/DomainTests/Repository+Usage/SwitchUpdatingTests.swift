//
//  SwitchUpdatingTests.swift
//  DomainTests
//
//  Created by sudo.park on 2022/08/31.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import XCTest
import RxSwift

import Domain
import UnitTestHelpKit

class SwitchUpdatingTests: BaseTestCase {
    
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
    
    private func doSwitchUpdating(
        isSignIn: Bool
    ) async throws -> [Int] {
        let auth: Auth? = isSignIn ? .init(userID: "some") : nil
        let provider = AuthInfoProviderImple(auth: auth)
        let remote = StubRemote()
        let updating = SwitchUpdating(authInfoProvider: provider, local: self.spyLocal!, remote: remote)
        return try await updating
            .do { remote, _ in
                try await remote.update([])
            } andUpdateCache: { local, result in
                _ = try await local.update(result)
            } orUpdateOnLocal: { local in
                try await local.update([])
            }
    }
}


extension SwitchUpdatingTests {
    
    func testSwitchUpdating_whenSignout_updateOnlyCache() async {
        // given
        // when
        let result = try? await self.doSwitchUpdating(isSignIn: false)
        
        // then
        XCTAssertEqual(result, [0])
    }
    
    func testSwitchUpdating_whenSignIn_updateRemote() async {
        // given
        // when
        let result = try? await self.doSwitchUpdating(isSignIn: true)
        
        // then
        XCTAssertEqual(result, [1])
    }
    
    func testSwitchUpdating_whenSignInUpdateRemote_andUpdateCache() {
        // given
        let expect = expectation(description: "로그인 상태에서 업데이트시에 리모트 먼저 업데이트 하고 캐시도 업데이트")
        var didUpdateCalledWith: [Int]?
        self.spyLocal.didUpdatedCalled = {
            expect.fulfill()
            didUpdateCalledWith = $0
        }
        
        // when
        let updating = Observable<[Int]>.create {
            try await self.doSwitchUpdating(isSignIn: true)
        }
        updating.subscribe().disposed(by: self.disposeBag)
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(didUpdateCalledWith, [1])
    }
}


private extension SwitchUpdatingTests {
    
    class StubLocal {
        
        var didUpdatedCalled: (([Int]) -> Void)?
        func update(_ ints: [Int]) async throws -> [Int] {
            self.didUpdatedCalled?(ints)
            return [0]
        }
    }
    
    class StubRemote {
        
        func update(_ ints: [Int]) async throws -> [Int] {
            return [1]
        }
    }
}
