//
//  BaseSwitchUpdaterTests.swift
//  RepositoryTests
//
//  Created by sudo.park on 2023/02/22.
//

import XCTest
import RxSwift
import RxSwiftDoNotation
import Extensions
import UnitTestHelpKit

@testable import Repository


// MARK: - BaseSingleSwitchUpdatingTests

class BaseSingleSwitchUpdatingTests<Result>: BaseRepositoryUsageTests {
    
    func stubResult() { }
    func stubFail() { }
    func updating() async throws -> Result { throw RuntimeError("not implemented") }
    func assertResult(_ result: Result?) -> Bool { true }
}

extension BaseSingleSwitchUpdatingTests {
    
    func testUpdater_save() async {
        // given
        self.stubResult()
        
        // when
        let result = try? await self.updating()
        
        // then
        XCTAssertEqual(self.assertResult(result), true)
    }
    
    func testUpdater_saveFail() async {
        // given
        self.stubFail()
        
        // when
        let result = try? await self.updating()
        
        // then
        XCTAssertNil(result)
    }
}


// MARK: - BaseDualSwitchUpdatingTests

class BaseDualSwitchUpdatingTests<Result>: BaseRepositoryUsageTests, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var didCacheUpdated: (() -> Void)?
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.didCacheUpdated = nil
    }
    
    func stubUpdate() { }
    func stubFailUpdate() { }
    func stubCacheUpdate() { }
    func stubCacheFailUpdate() { }
    
    func updating() async throws -> Result { throw RuntimeError("not implemented") }
    func assertResult(_ result: Result?) -> Bool { return true }
}

extension BaseDualSwitchUpdatingTests {
    
    // save main and cache
    func testUpdater_update() async {
        // given
        self.stubUpdate()
        self.stubCacheUpdate()
        
        // when
        let result = try? await self.updating()
        
        // then
        XCTAssertEqual(self.assertResult(result), true)
    }
    
    // save fail -> fail
    func testUpdater_whenUpdateMainStorageFail_fail() async {
        // given
        self.stubFailUpdate()
        self.stubCacheUpdate()
        
        // when
        let result = try? await self.updating()
        
        // then
        XCTAssertNil(result)
    }
    
    // save main but cache fail
    func testUpdater_whenUpdateCacheFail_ignore() async {
        // given
        self.stubUpdate()
        self.stubCacheFailUpdate()
        
        // when
        let result = try? await self.updating()
        
        // then
        XCTAssertEqual(self.assertResult(result), true)
    }
}
