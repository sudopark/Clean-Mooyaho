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
    
    func testRepo_fetchLastSignInMember() {
        // given
        let expect = expectation(description: "마지막으로 로그인했던 유저 로드")
        
        self.stubLocal.register(type: Maybe<Member?>.self, key: "fetchCurrentMember") {
            return .just(Member(uid: "dummy"))
        }
        
        // when
        let member = self.waitFirstElement(expect, for: self.repository.fetchLastSignInMember().asObservable()) { } ?? nil
        
        // then
        XCTAssertNotNil(member)
    }
    
    func testRepo_whenLastSignInMemberNotExists_signinAnonymously() {
        // given
        let expect = expectation(description: "마지막으로 로그인했던 유저 없으면 익명로그인 진행")
        self.stubLocal.register(type: Maybe<Member?>.self, key: "fetchCurrentMember") { .just(nil) }
        
        self.stubRemote.called(key: "requestSignInAnonymously") { _ in
            expect.fulfill()
        }
        
        // when
        self.repository.fetchLastSignInMember()
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testRepo_whenSignIn_returnsMember() {
        // given
        let expect = expectation(description: "로그인 이후에 멤버정보 반환")
        self.stubRemote.register(type: Maybe<DataModels.Member>.self, key: "requestSignIn:withEmail") {
            return .just(DataModels.Member(uid: "new.member.id"))
        }
        
        // when
        let secret = EmailBaseSecret(email: "", password: "")
        let member = self.waitFirstElement(expect, for: self.repository.requestSignIn(using: secret).asObservable()) {}
        
        // then
        XCTAssertEqual(member?.uid, "new.member.id")
    }
    
    func testRepo_whenAfterSignIn_saveMemberDataAtLocal() {
        // given
        let expect = expectation(description: "로그인 성공 이후에 로컬에 멤버정보 저장")
        self.stubRemote.register(type: Maybe<DataModels.Member>.self, key: "requestSignIn:withEmail") {
            return .just(DataModels.Member(uid: "new.member.id"))
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
