//
//  RepositoryTests+Auth.swift
//  DataStoreTests
//
//  Created by ParkHyunsoo on 2021/05/02.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit

@testable import DataStore


class RepositoryTests_Auth: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var stubRemote: StubRemote!
    var stubLocal: StubLocal!
    var repository: DummyRepository!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = DisposeBag()
        self.stubRemote = StubRemote()
        self.stubLocal = StubLocal()
        self.repository = DummyRepository(remote: self.stubRemote, local: self.stubLocal)
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.stubLocal = nil
        self.stubRemote = nil
        self.repository = nil
        super.tearDown()
    }
}



extension RepositoryTests_Auth {
    
    func testRepo_whenSignIn_returnsMember() {
        // given
        let expect = expectation(description: "로그인 이후에 멤버정보 반환")
        self.stubRemote.register(type: Maybe<Member>.self, key: "requestSignIn") {
            return .just(Customer(memberID: "new.member.id"))
        }
        
        // when
        let credential = EmailBaseCredential(email: "", password: "")
        let member = self.waitFirstElement(expect, for: self.repository.signIn(using: credential).asObservable()) { }
        
        // then
        XCTAssertEqual(member?.memberID, "new.member.id")
    }
    
    func testRepo_whenAfterSignIn_saveMemberDataAtLocal() {
        // given
        let expect = expectation(description: "로그인 성공 이후에 로컬에 멤버정보 저장")
        self.stubRemote.register(type: Maybe<Member>.self, key: "requestSignIn") {
            return .just(Customer(memberID: "new.member.id"))
        }
        
        self.stubLocal.called(key: "saveSignedIn:member") { _ in
            expect.fulfill()
        }
        
        // when
        let credential = EmailBaseCredential(email: "", password: "")
        self.repository.signIn(using: credential)
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}


extension RepositoryTests_Auth {
    
    class DummyRepository: AuthRepository, AuthRepositoryDefImpleDependency {
        let disposeBag: DisposeBag = DisposeBag()
        let remote: Remote
        let local: Local
        init(remote: Remote, local: Local) {
            self.remote = remote
            self.local = local
        }
    }
}
