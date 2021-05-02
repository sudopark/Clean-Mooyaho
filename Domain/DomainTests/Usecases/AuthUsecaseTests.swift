//
//  AuthUsecaseTests.swift
//  DomainTests
//
//  Created by ParkHyunsoo on 2021/04/29.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import UnitTestHelpKit

@testable import Domain


class AuthUsecaseTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    private var stubAuthRepo: StubAuthRepository!
    private var stubOAuth2Repo: StubOAuth2Repository!
    private var usecase: AuthUsecaseImple!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = DisposeBag()
        self.stubAuthRepo = .init()
        self.stubOAuth2Repo = .init()
        self.usecase = AuthUsecaseImple(authRepository: self.stubAuthRepo,
                                        socialAuthRepository: self.stubOAuth2Repo)
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.stubAuthRepo = nil
        self.stubOAuth2Repo = nil
        self.usecase = nil
        super.tearDown()
    }
}


// MARK: login

extension AuthUsecaseTests {
    
    func testUsecase_loadMember() {
        // given
        let expect = expectation(description: "멤버정보 로드")
        self.stubAuthRepo.register(key: "fetchLastSignInMember") {
            return Maybe<Member?>.just(Member(uid: "uuid"))
        }
        
        // when
        let member = self.waitFirstElement(expect, for: self.usecase.loadCurrentMember().asObservable()) { } ?? nil
        
        // then
        XCTAssertEqual(member?.uid, "uuid")
    }
    
    func testUsecase_whenNotSingInBefore_loadMemberResultIsNil() {
        // given
        let expect = expectation(description: "마지막에 로그인한 이력 없으면 조회결과 nil")
        self.stubAuthRepo.register(key: "fetchLastSignInMember") {
            return Maybe<Member?>.just(nil)
        }
        
        // when
        let member = self.waitFirstElement(expect, for: self.usecase.loadCurrentMember().asObservable()) { } ?? nil
        
        // then
        XCTAssertNil(member)
    }
    
    func testUsecase_signInUsingEmailBaseSecret() {
        // given
        let expect = expectation(description: "이메일 정보로 로그인")
        self.stubAuthRepo.register(key: "requestSignIn:secret") {
            return Maybe<Member>.just(Member(uid: "new_uuid"))
        }
        
        // when
        let secret = EmailBaseSecret(email: "email@com", password: "password")
        let member = self.waitFirstElement(expect, for: self.usecase.requestSignIn(emailBaseSecret: secret).asObservable()) { }
        
        // then
        XCTAssertNotNil(member)
    }
    
    func testUsecase_oauth2SignIn() {
        // given
        let expect = expectation(description: "소셜 로그인 요청 이후에 서비스 로그인 성공시 새로운 멤버 정보 반환")
        
        self.stubOAuth2Repo.register(key: "requestSignIn") {
            return Maybe<OAuthCredential>.just(DummyOAuth2Credentail())
        }
        self.stubAuthRepo.register(key: "requestSignIn:credential") {
            return Maybe<Member>.just(Member(uid: "new_uuid"))
        }
        
        // when
        let member = self.waitFirstElement(expect, for: self.usecase.requestSocialSignIn().asObservable()) { }
        
        // then
        XCTAssertEqual(member?.uid, "new_uuid")
    }
    
    func testUsecase_whenOauth2SignInFail_resultIsFail() {
        // given
        let expect = expectation(description: "소셜 로그인 실패시에 로그인 실패")
        struct DummyError: Error {}
        self.stubOAuth2Repo.register(key: "requestSignIn") {
            return Maybe<OAuthCredential>.error(AuthErrors.oauth2Fail(DummyError()))
        }
        
        // when
        let error = self.waitError(expect, for: self.usecase.requestSocialSignIn().asObservable()) { }
        
        // then
        if let authError = error as? AuthErrors, case .oauth2Fail = authError {
            XCTAssert(true)
        } else {
            XCTFail("기대하는 에러가 아님")
        }
    }
    
    // 소셜 로그인은 성공했지만 서비스 로그인 실패시에 에러 반환
    func testUsecase_whenServiceSignInFail_resultIsFail() {
        // given
        let expect = expectation(description: "소셜 로그인 성공 이후에 서비스 로그인 실패")
        
        self.stubOAuth2Repo.register(key: "requestSignIn") {
            return Maybe<OAuthCredential>.just(DummyOAuth2Credentail())
        }
        struct DummyError: Error {}
        self.stubAuthRepo.register(key: "requestSignIn:credential") {
            return Maybe<Member>.error(DummyError())
        }
        
        // when
        let error = self.waitError(expect, for: self.usecase.requestSocialSignIn().asObservable()) { }
        
        // then
        XCTAssertNotNil(error)
    }
    
    // 로그인 성공시 공유되는 현제 멤버정보 방출
}


// MARK: logout

extension AuthUsecaseTests {
    
    // 로그인 안한 상태에서 로그아웃시 그냥 성공
    
    // 로그인 상태에서 로그아웃시 익명유저 반환
}


extension AuthUsecaseTests {
    
    struct DummyOAuth2Credentail: OAuthCredential { }
}
