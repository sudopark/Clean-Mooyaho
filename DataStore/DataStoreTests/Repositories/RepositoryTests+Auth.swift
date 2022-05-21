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
    var mockRemote: MockRemote!
    var mockLocal: MockLocal!
    var repository: DummyRepository!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = DisposeBag()
        self.mockRemote = MockRemote()
        self.mockLocal = MockLocal()
        self.repository = DummyRepository(remote: self.mockRemote, local: self.mockLocal)
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.mockLocal = nil
        self.mockRemote = nil
        self.repository = nil
        super.tearDown()
    }
}


// MARK: - signin

extension RepositoryTests_Auth {
    
    private func registerLastAccountInfo(_ auth: Auth?, _ member: Member?) {
        self.mockLocal.register(key: "fetchCurrentAuth") {
            return Maybe<Auth?>.just(auth)
        }
        
        self.mockLocal.register(key: "fetchCurrentMember") {
            return Maybe<Member?>.just(member)
        }
    }
    
    func testRepo_fetchLastSignInAccountInfo() {
        // given
        let expect = expectation(description: "마지막으로 로그인했던 계정정보 로드")
        
        self.registerLastAccountInfo(Auth(userID: "dummy"), Member(uid: "dummy"))
        
        // when
        let requestLoad = self.repository.fetchLastSignInAccountInfo()
        let account = self.waitFirstElement(expect, for: requestLoad.asObservable()) { } ?? nil
        
        // then
        XCTAssertNotNil(account?.0)
        XCTAssertNotNil(account?.1)
    }
    
    func testRepo_whenFetchLastSignInAccountInfoWithSignIn_openUserStorage() {
        // given
        let expect = expectation(description: "로그인상태에서 마지막 로그인정보 로드시 유저 스토리지 오픈")
        let auth = Auth(userID: "some")
        self.registerLastAccountInfo(auth, Member(uid: "some", nickName: nil, icon: nil))
        
        self.mockLocal.called(key: "openStorage-some") { _ in
            expect.fulfill()
        }
        
        // when
        self.repository.fetchLastSignInAccountInfo()
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testRepo_whenFetchLastSignInAccountInfoWithSignInButNoMemberInfo_switchToAnonymousStorage() {
        // given
        let auth = Auth(userID: "some")
        self.registerLastAccountInfo(auth, nil)
        
        // when
        self.repository.fetchLastSignInAccountInfo()
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        XCTAssertEqual(self.mockLocal.didSwitchToAnonymousStorage, true)
    }
    
    func testRepo_whenLastSignInMemberNotExists_signinAnonymously() {
        // given
        let expect = expectation(description: "마지막으로 로그인했던 유저 없으면 익명로그인 진행")
        self.registerLastAccountInfo(nil, nil)
        
        self.mockRemote.register(key: "requestSignInAnonymously") {
            return Maybe<Auth>.just(Auth(userID: "dummy"))
        }
       
        // when
        let requestLoad = self.repository.fetchLastSignInAccountInfo()
        let account = self.waitFirstElement(expect, for: requestLoad.asObservable()) { } ?? nil
        
        // then
        XCTAssertNotNil(account?.0)
        XCTAssertNil(account?.1)
    }
    
    func testRepo_whenFetchLastSignInMemberError_returnsNil() {
        // given
        let expect = expectation(description: "마지막 로그인 멤버정보 로드시에 에러 발생하면 nil 리턴")
        self.mockLocal.register(key: "fetchCurrentAuth") {
            return Maybe<Auth?>.just(Auth(userID: "some"))
        }
        
        self.mockLocal.register(key: "fetchCurrentMember") {
            return Maybe<Member?>.error(ApplicationErrors.invalid)
        }
        self.mockRemote.register(key: "requestSignInAnonymously") {
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
        self.mockRemote.register(type: Maybe<SigninResult>.self, key: "requestSignIn:withEmail") {
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
        expect.expectedFulfillmentCount = 2
        self.mockRemote.register(type: Maybe<SigninResult>.self, key: "requestSignIn:withEmail") {
            let auth = Auth(userID: "dummy")
            let member = Member(uid: "dummy")
            return .just(.init(auth: auth, member: member))
        }
        
        self.mockLocal.called(key: "switchToUserStorage") { any in
            guard let userID = any as? String, userID == "dummy" else { return }
            expect.fulfill()
        }
        
        self.mockLocal.called(key: "saveSignedIn:member") { _ in
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
    
    // 로그아웃시에 디비 바꿈
    func testRepository_whenSignout_changeDatabase() {
        // given
        let expect = expectation(description: "로그아웃시에 로그아웃처리하고 디비 바꿈")
        self.mockRemote.register(key: "requestSignout") { Maybe<Void>.just() }
        
        // when
        let signout = repository.requestSignout()
        let result: Void? = self.waitFirstElement(expect, for: signout.asObservable())
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(self.mockLocal.didSwitchToAnonymousStorage, true)
    }
    
    func testRepository_whenSignout_clearUserEnvironment() {
        // given
        let expect = expectation(description: "로그아웃시에 유저 environment 초기화")
        self.mockRemote.register(key: "requestSignout") { Maybe<Void>.just() }
        
        self.mockLocal.called(key: "clearUserEnvironment") { _ in
            expect.fulfill()
        }
        
        // when
        self.repository.requestSignout()
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testReposiotry_whenWithdrawal_requestWithdrawalAndChangeDatabase() {
        // given
        let expect = expectation(description: "회원탈퇴시에 로그아웃플로우타고 디비 체인지")
        self.mockRemote.register(key: "requestWithdrawal") { Maybe<Void>.just() }
        self.mockLocal.register(key: "removeUserStorage") { Maybe<Void>.just() }
        self.mockRemote.register(key: "requestSignout") { Maybe<Void>.just() }
        
        // when
        let withdrawal = repository.requestWithdrawal()
        let result: Void? = self.waitFirstElement(expect, for: withdrawal.asObservable())
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(self.mockLocal.didSwitchToAnonymousStorage, true)
    }
    
    func testRepository_recoverAccount() {
        // given
        let expect = expectation(description: "계정 복구")
        self.mockRemote.register(type: Maybe<Member>.self, key: "requestRecoverAccount") {
            var member = Member(uid: "some", nickName: nil, icon: nil)
            member.deactivatedDateTimeStamp = .now()
            return .just(member)
        }
        
        // when
        let recovering = self.repository.requestRecoverAccount()
        let newMember = self.waitFirstElement(expect, for: recovering.asObservable())
        
        // then
        XCTAssertNotNil(newMember)
    }
    
    func testRepository_whenRecoverAccount_activateMemberAndUpdateLocal() {
        // given
        let expect = expectation(description: "계정 복구시에 복구하고 로컬 업데이트")
        var isMemberUdpated: Bool?
        self.mockRemote.register(type: Maybe<Member>.self, key: "requestRecoverAccount") {
            return .just(Member(uid: "some", nickName: nil, icon: nil))
        }
        self.mockLocal.called(key: "saveSignedIn:member") { _ in
            isMemberUdpated = true
            expect.fulfill()
        }
        
        // when
        self.repository.requestRecoverAccount()
            .subscribe()
            .disposed(by: self.disposeBag)
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(isMemberUdpated, true)
    }
}


extension RepositoryTests_Auth {
    
    class DummyRepository: AuthRepository, AuthRepositoryDefImpleDependency {
        let disposeBag: DisposeBag = DisposeBag()
        let authRemote: AuthRemote
        let authLocal: AuthLocalStorage & DataModelStorageSwitchable
        init(remote: Remote, local: LocalStorage) {
            self.authRemote = remote
            self.authLocal = local
        }
    }
}
