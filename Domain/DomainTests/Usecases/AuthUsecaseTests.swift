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
    private var mockAuthRepo: MockAuthRepository!
    private var mockOAuth2Repo: MockOAuthService!
    private var store: SharedDataStoreServiceImple!
    private var spySearchReposiotry: StubSearchRepository!
    private var usecase: AuthUsecaseImple!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = DisposeBag()
        self.mockAuthRepo = .init()
        self.mockOAuth2Repo = .init()
        self.store = .init()
        self.spySearchReposiotry = .init()
        self.usecase = AuthUsecaseImple(authRepository: self.mockAuthRepo,
                                        oathServiceProviders: [self.mockOAuth2Repo],
                                        authInfoManager: self.store,
                                        sharedDataStroeService: self.store,
                                        searchReposiotry: self.spySearchReposiotry)
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.mockAuthRepo = nil
        self.mockOAuth2Repo = nil
        self.store = nil
        self.spySearchReposiotry = nil
        self.usecase = nil
        super.tearDown()
    }
}


// MARK: login

extension AuthUsecaseTests {
    
    func testUsecase_loadLastAccountInfo() {
        // given
        let expect = expectation(description: "마지막 이용한 계정정보 반환")
        self.mockAuthRepo.register(key: "fetchLastSignInAccountInfo") {
            return Maybe<(Auth, Member?)>.just((Auth(userID: "dummy"), Member(uid: "dummy")))
        }
        
        // when
        let requestLoad = self.usecase.loadLastSignInAccountInfo()
        let info = self.waitFirstElement(expect, for: requestLoad.asObservable()) { }
        
        // then
        XCTAssertNotNil(info?.auth)
        XCTAssertNotNil(info?.member)
    }
    
    private func assertAuthAndMemberInfoUpdatedOnStore(_ expect: XCTestExpectation,
                                                       _ action: @escaping () -> Void) {
        let auths: Observable<Auth> = self.usecase.currentAuth.compactMap{ $0 }
        let members = self.store.observe(Member.self, key:SharedDataKeys.currentMember.rawValue)
        let source = Observable.combineLatest(auths, members)
        let pair = self.waitFirstElement(expect, for: source, action: action)
        XCTAssertNotNil(pair?.0)
        XCTAssertNotNil(pair?.1)
    }
    
    func testUsecase_whenLoadLastAccountInfo_updateOnStores() {
        // given
        let expect = expectation(description: "마지막 이용한 계정정보 로드시 공용 스토어에 저장")
        self.mockAuthRepo.register(key: "fetchLastSignInAccountInfo") {
            return Maybe<(Auth, Member?)>.just((.signIn("dummy"), Member(uid: "dummy")))
        }
        
        // when + then
        self.assertAuthAndMemberInfoUpdatedOnStore(expect) {
            self.usecase.loadLastSignInAccountInfo()
                .subscribe()
                .disposed(by: self.disposeBag)
        }
    }
    
    func testUsecase_signInUsingEmailBaseSecret() {
        // given
        let expect = expectation(description: "이메일 정보로 로그인")
        self.mockAuthRepo.register(key: "requestSignIn:secret") {
            return Maybe<SigninResult>.just(.dummy("new_uuid"))
        }
        
        // when
        let secret = EmailBaseSecret(email: "email@com", password: "password")
        let member = self.waitFirstElement(expect, for: self.usecase.requestSignIn(emailBaseSecret: secret).asObservable()) { }
        
        // then
        XCTAssertNotNil(member)
    }
    
    func testUsecase_whenAfterEmailBaseLogin_updateResultOnStore() {
        // given
        let expect = expectation(description: "이메일로 로그인 이후에 스토어에 정보 업데이트")
        self.mockAuthRepo.register(key: "requestSignIn:secret") {
            return Maybe<SigninResult>.just(.dummy("new_uuid"))
        }
        
        // when + then
        self.assertAuthAndMemberInfoUpdatedOnStore(expect) {
            let secret = EmailBaseSecret(email: "email@com", password: "password")
            self.usecase.requestSignIn(emailBaseSecret: secret)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
    }
    
    func testUsecase_whenAfterEmailBaseLogin_downloadSuggestableQueries() {
        // given
        let expect = expectation(description: "이메일로 로그인 이후에 서제스트가능한 쿼리 다운로드")
        self.mockAuthRepo.register(key: "requestSignIn:secret") {
            return Maybe<SigninResult>.just(.dummy("new_uuid"))
        }
        
        // when + then
        self.assertAuthAndMemberInfoUpdatedOnStore(expect) {
            let secret = EmailBaseSecret(email: "email@com", password: "password")
            self.usecase.requestSignIn(emailBaseSecret: secret)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        XCTAssertEqual(self.spySearchReposiotry.didDownloaded, true)
    }
    
    func testUsecase_oauth2SignIn() {
        // given
        let expect = expectation(description: "소셜 로그인 요청 이후에 서비스 로그인 성공시 새로운 멤버 정보 반환")
        
        self.mockOAuth2Repo.register(key: "requestSignIn") {
            return Maybe<OAuthCredential>.just(DummyOAuth2Credentail())
        }
        self.mockAuthRepo.register(key: "requestSignIn:credential") {
            return Maybe<SigninResult>.just(.dummy("new_uuid"))
        }
        
        // when
        let requestSignIn = self.usecase.requestSocialSignIn(DummyOAuthType())
        let member = self.waitFirstElement(expect, for: requestSignIn.asObservable())
        
        // then
        XCTAssertEqual(member?.uid, "new_uuid")
    }
    
    func testUsecase_whenAfterSocialLogin_updateResultOnStore() {
        // given
        let expect = expectation(description: "소셜 로그인 이후에 스토어에 정보 업데이트")
        self.mockOAuth2Repo.register(key: "requestSignIn") {
            return Maybe<OAuthCredential>.just(DummyOAuth2Credentail())
        }
        self.mockAuthRepo.register(key: "requestSignIn:credential") {
            return Maybe<SigninResult>.just(.dummy("new_uuid"))
        }
        
        // when + then
        self.assertAuthAndMemberInfoUpdatedOnStore(expect) {
            self.usecase.requestSocialSignIn(DummyOAuthType())
                .subscribe()
                .disposed(by: self.disposeBag)
        }
    }
    
    func testUsecase_whenAfterSocialLogin_downloadSuggestableQueries() {
        // given
        let expect = expectation(description: "소셜 로그인 이후에 서제스트가능한 쿼리 다운로드")
        self.mockOAuth2Repo.register(key: "requestSignIn") {
            return Maybe<OAuthCredential>.just(DummyOAuth2Credentail())
        }
        self.mockAuthRepo.register(key: "requestSignIn:credential") {
            return Maybe<SigninResult>.just(.dummy("new_uuid"))
        }
        
        // when + then
        self.assertAuthAndMemberInfoUpdatedOnStore(expect) {
            self.usecase.requestSocialSignIn(DummyOAuthType())
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        XCTAssertEqual(self.spySearchReposiotry.didDownloaded, true)
    }
    
    // 로그인 성공시 공유되는 현제 멤버정보 방출
    func testUsecase_whenAfterSignInSuccess_updateSharedMemberInfo() {
        // given
        let expect = expectation(description: "로그인 이후 스토어에 currentMember 업데이트시에 memberMap도 업데이트")
        self.mockOAuth2Repo.register(key: "requestSignIn") {
            return Maybe<OAuthCredential>.just(DummyOAuth2Credentail())
        }
        self.mockAuthRepo.register(key: "requestSignIn:credential") {
            return Maybe<SigninResult>.just(.dummy("new_uuid"))
        }
        
        // when
        let key = SharedDataKeys.memberMap.rawValue
        let memberMapSource = self.store.observe([String: Member].self, key: key)
        let memberMap = self.waitFirstElement(expect, for: memberMapSource) {
            self.usecase.requestSocialSignIn(DummyOAuthType())
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        // then
        let me = memberMap?["new_uuid"]
        XCTAssertNotNil(me)
    }
    
    func testUsecase_whenOauth2SignInFail_resultIsFail() {
        // given
        let expect = expectation(description: "소셜 로그인 실패시에 로그인 실패")
        struct DummyError: Error {}
        self.mockOAuth2Repo.register(key: "requestSignIn") {
            return Maybe<OAuthCredential>.error(AuthErrors.oauth2Fail(DummyError()))
        }
        
        // when
        let requestSignIn = self.usecase.requestSocialSignIn(DummyOAuthType())
        let error = self.waitError(expect, for: requestSignIn.asObservable())
        
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
        
        self.mockOAuth2Repo.register(key: "requestSignIn") {
            return Maybe<OAuthCredential>.just(DummyOAuth2Credentail())
        }
        struct DummyError: Error {}
        self.mockAuthRepo.register(key: "requestSignIn:credential") {
            return Maybe<SigninResult>.error(DummyError())
        }
        
        // when
        let requestSignIn = self.usecase.requestSocialSignIn(DummyOAuthType())
        let error = self.waitError(expect, for: requestSignIn.asObservable())
        
        // then
        XCTAssertNotNil(error)
    }
}


// MARK: logout

extension AuthUsecaseTests {
    
    func testusecase_whenAftterSignout_publishNewAnonymousAccount() {
        // given
        let expect = expectation(description: "로그아웃 이후에 새로운 익명계정 발급")
        self.mockAuthRepo.register(key: "requestSignout") { Maybe<Void>.just() }
        self.mockAuthRepo.register(key: "signInAnonymouslyForPrepareDataAcessPermission") {
            return Maybe<Auth>.just(.init(userID: "some"))
        }
        
        // when
        let signout = self.usecase.requestSignout()
        let newAuth = self.waitFirstElement(expect, for: signout.asObservable())
        
        // then
        XCTAssertNotNil(newAuth)
    }
    
    func testUsecase_whenAfterSignout_clearSharedDataStore() {
        // given
        let expect = expectation(description: "로그아웃 이후에 데이터스토어 초기화")
        self.mockAuthRepo.register(key: "requestSignout") { Maybe<Void>.just() }
        self.mockAuthRepo.register(key: "signInAnonymouslyForPrepareDataAcessPermission") {
            return Maybe<Auth>.just(.init(userID: "some"))
        }
        
        // when
        let signout = self.usecase.requestSignout()
        let _ = self.waitFirstElement(expect, for: signout.asObservable())
        
        // then
        XCTAssertEqual(self.store.isEmpty, true)
    }
    
    func testUseacse_whenAfterSignout_notifySignedOut() {
        // given
        let expect = expectation(description: "로그아웃 이후에 로그아웃 되었음을 알림")
        self.mockAuthRepo.register(key: "requestSignout") { Maybe<Void>.just() }
        self.mockAuthRepo.register(key: "signInAnonymouslyForPrepareDataAcessPermission") {
            return Maybe<Auth>.just(.init(userID: "some"))
        }
        
        // when
        let newAuth = self.waitFirstElement(expect, for: usecase.signedOut) {
            self.usecase.requestSignout()
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        // then
        XCTAssertNotNil(newAuth)
    }
}


extension AuthUsecaseTests {
    
    struct DummyOAuth2Credentail: OAuthCredential { }
}

private extension Auth {
    
    static func signIn(_ id: String) -> Auth {
        return Auth(userID: id)
    }
}
