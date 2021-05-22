//
//  RepositoryTests+Member.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/05/20.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit

@testable import DataStore


class RepositoryTests_Member: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var stubRemote: StubRemote!
    var stubLocal: StubLocal!
    var repository: DummyRepository!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = .init()
        self.stubLocal = .init()
        self.stubRemote = .init()
        self.repository = .init(remote: self.stubRemote, local: self.stubLocal)
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.stubRemote = nil
        self.stubLocal = nil
        self.repository = nil
        super.tearDown()
    }
}


extension RepositoryTests_Member {
    
    func testRepository_updateUserPresence() {
        // given
        let expect = expectation(description: "user presence 업데이트")
        
        self.stubRemote.register(key: "requestUpdateUserPresence") {
            return Maybe<Void>.just()
        }
        
        // when
        let requestUpdate = self.repository.requestUpdateUserPresence("som", isOnline: true)
        let void: Void? = self.waitFirstElement(expect, for: requestUpdate.asObservable()) { }
        
        // then
        XCTAssertNotNil(void)
    }
}


extension RepositoryTests_Member {
    
    class DummyRepository: MemberRepository, MemberRepositoryDefImpleDependency {
        
        let memberRemote: MemberRemote
        
        init(remote: MemberRemote, local: HoorayLocalStorage) {
            self.memberRemote = remote
        }
    }
}
