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


// MARK: - signin

extension RepositoryTests_Auth {
    
    private func stubLastAccountInfo(_ auth: Auth?, _ member: Member?) {
        self.stubLocal.register(key: "fetchCurrentAuth") {
            return Maybe<Auth?>.just(auth)
        }
        
        self.stubLocal.register(key: "fetchCurrentMember") {
            return Maybe<Member?>.just(member)
        }
    }
    
    func testRepo_fetchLastSignInAccountInfo() {
        // given
        let expect = expectation(description: "마지막으로 로그인했던 계정정보 로드")
        
        self.stubLastAccountInfo(Auth(userID: "dummy"), Member(uid: "dummy"))
        
        // when
        let requestLoad = self.repository.fetchLastSignInAccountInfo()
        let account = self.waitFirstElement(expect, for: requestLoad.asObservable()) { } ?? nil
        
        // then
        XCTAssertNotNil(account?.0)
        XCTAssertNotNil(account?.1)
    }
    
    func testRepo_whenLastSignInMemberNotExists_signinAnonymously() {
        // given
        let expect = expectation(description: "마지막으로 로그인했던 유저 없으면 익명로그인 진행")
        self.stubLastAccountInfo(nil, nil)
        
        self.stubRemote.register(key: "requestSignInAnonymously") {
            return Maybe<Auth>.just(Auth(userID: "dummy"))
        }
       
        // when
        let requestLoad = self.repository.fetchLastSignInAccountInfo()
        let account = self.waitFirstElement(expect, for: requestLoad.asObservable()) { } ?? nil
        
        // then
        XCTAssertNotNil(account?.0)
        XCTAssertNil(account?.1)
    }
    
    func testRepo_signInWithEmail() {
        // given
        let expect = expectation(description: "이메일로 로그인")
        self.stubRemote.register(type: Maybe<SigninResult>.self, key: "requestSignIn:withEmail") {
            let auth = Auth(userID: "dummy")
            let member = Member(uid: "dummy")
            return .just(.init(auth: auth, member: member))
        }
        
        // when
        let secret = EmailBaseSecret(email: "", password: "")
        let result = self.waitFirstElement(expect, for: self.repository.requestSignIn(using: secret).asObservable()) {}
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepo_whenAfterSignIn_saveMemberDataAtLocal() {
        // given
        let expect = expectation(description: "로그인 성공 이후에 로컬에 멤버정보 저장")
        self.stubRemote.register(type: Maybe<SigninResult>.self, key: "requestSignIn:withEmail") {
            let auth = Auth(userID: "dummy")
            let member = Member(uid: "dummy")
            return .just(.init(auth: auth, member: member))
        }
        
        self.stubLocal.called(key: "saveSignedIn:member") { _ in
            expect.fulfill()
        }
        
        // when
        let secret = EmailBaseSecret(email: "", password: "")
        self.repository.requestSignIn(using: secret)
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
        let local: LocalStorage
        init(remote: Remote, local: LocalStorage) {
            self.remote = remote
            self.local = local
        }
    }
}
