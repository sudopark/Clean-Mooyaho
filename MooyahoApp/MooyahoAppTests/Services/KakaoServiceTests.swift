//
//  KakaoServiceTests.swift
//  MooyahoAppTests
//
//  Created by sudo.park on 2021/05/29.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Domain
import DataStore
import UnitTestHelpKit

@testable import MooyahoApp


class KakaoServiceTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var stubRemote: StubRemote!
    var service: KakaoServiceImple!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.stubRemote = .init()
        self.service = .init(remote: self.stubRemote)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.stubRemote = nil
        self.service = nil
    }
}


extension KakaoServiceTests {
    
    func testService_signinAndVerify_withKakaoTalk() {
        // given
        let expect = expectation(description: "카톡으로 로그인해서 credential 발급")
        self.stubRemote.register(key: "isKakaoTalkLoginAvailable") { true }
        self.stubRemote.register(key: "loginWithKakaoTalk") { Maybe<String>.just("ko_token") }
        self.stubRemote.register(key: "verifyKakaoAccessToken") { Maybe<String>.just("firebase_token") }
        
        // when
        let requestSignin = self.service.requestSignIn()
        let credential = self.waitFirstElement(expect, for: requestSignin.asObservable()) { }
        
        // then
        XCTAssert(credential is CustomTokenCredential)
    }
    
    func testService_signinAndVerify_withKakaoAccount() {
        // given
        let expect = expectation(description: "카카오 계정으로 로그인해서 credential 발급")
        self.stubRemote.register(key: "isKakaoTalkLoginAvailable") { false }
        self.stubRemote.register(key: "loginWithKakaoAccount") { Maybe<String>.just("ko_token") }
        self.stubRemote.register(key: "verifyKakaoAccessToken") { Maybe<String>.just("firebase_token") }
        
        // when
        let requestSignin = self.service.requestSignIn()
        let credential = self.waitFirstElement(expect, for: requestSignin.asObservable()) { }
        
        // then
        XCTAssert(credential is CustomTokenCredential)
    }
    
    func testService_whenRequestSignin_kakaoTalkSigninFail() {
        // given
        let expect = expectation(description: "카카오톡 로그인 실패")
        self.stubRemote.register(key: "isKakaoTalkLoginAvailable") { true }
        self.stubRemote.register(key: "loginWithKakaoTalk") { Maybe<String>.error(KakaoOAuthErrors.failToSignIn(nil)) }
        
        // when
        let requestSignin = self.service.requestSignIn()
        let error = self.waitError(expect, for: requestSignin.asObservable()) { }
        
        // then
        XCTAssertNotNil(error)
    }
    
    func testService_whenRequestSignin_kakaoAccountSigninFail() {
        // given
        let expect = expectation(description: "카카오 계정으로 로그인 실패")
        self.stubRemote.register(key: "isKakaoTalkLoginAvailable") { false }
        self.stubRemote.register(key: "loginWithKakaoAccount") { Maybe<String>.error(KakaoOAuthErrors.failToSignIn(nil)) }
        
        // when
        let requestSignin = self.service.requestSignIn()
        let error = self.waitError(expect, for: requestSignin.asObservable()) { }
        
        // then
        XCTAssertNotNil(error)
    }
    
    func testService_whenKakaoSignInEnd_butVerifyFail() {
        // given
        let expect = expectation(description: "카카오 로그인은 성공했지만 인증은 실패")
        self.stubRemote.register(key: "isKakaoTalkLoginAvailable") { true }
        self.stubRemote.register(key: "loginWithKakaoTalk") { Maybe<String>.just("ko_token") }
        self.stubRemote.register(key: "verifyKakaoAccessToken") { Maybe<String>.error(KakaoOAuthErrors.failToSignIn(nil)) }
        
        // when
        let requestSignin = self.service.requestSignIn()
        let error = self.waitError(expect, for: requestSignin.asObservable()) { }
        
        // then
        XCTAssertNotNil(error)
    }
}


extension KakaoServiceTests {
    
    
    class StubRemote: KakaoOAuthRemote, Stubbable {
        
        func isKakaoTalkLoginAvailable() -> Bool {
            return self.resolve(key: "isKakaoTalkLoginAvailable") ?? false
        }
        
        func loginWithKakaoTalk() -> Maybe<String> {
            return self.resolve(key: "loginWithKakaoTalk") ?? .empty()
        }
        
        func loginWithKakaoAccount() -> Maybe<String> {
            return self.resolve(key: "loginWithKakaoAccount") ?? .empty()
        }
        
        func verifyKakaoAccessToken(_ token: String) -> Maybe<String> {
            return self.resolve(key: "verifyKakaoAccessToken") ?? .empty()
        }
        
    }
}
