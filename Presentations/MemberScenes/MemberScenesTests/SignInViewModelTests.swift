//
//  SignInViewModelTests.swift
//  MemberScenesTests
//
//  Created by sudo.park on 2021/05/30.
//

import XCTest

import RxSwift

import Domain
import StubUsecases
import UnitTestHelpKit

@testable import MemberScenes


class SignInViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var mockAuthUsecase: MockAuthUsecase!
    var spyRouter: SpyRouter!
    var viewModel: SignInViewModelImple!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.mockAuthUsecase = .init()
        self.spyRouter = .init()
        self.viewModel = .init(authUsecase: self.mockAuthUsecase,
                               router: self.spyRouter)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.mockAuthUsecase = nil
        self.spyRouter = nil
        self.viewModel = nil
    }
}


extension SignInViewModelTests {
    
    func testViewModel_presentSupportingOAuthProviderTypes() {
        // given
        self.mockAuthUsecase.supportingOAuthProviders = [
            OAuthServiceProviderTypes.kakao,
            OAuthServiceProviderTypes.apple
        ]
        // when
        let providers = self.viewModel.supportingOAuthProviderTypes
        
        // then
        XCTAssertEqual(providers.count, 2)
    }
    
    func testViewModel_whenSignIning_showProcessing() {
        // given
        let expect = expectation(description: "로그인시 처리중 상태 변경 -> 종료 이후에 처리중 false로 안바꿈")
        expect.expectedFulfillmentCount = 2
        
        self.mockAuthUsecase.register(key: "requestSocialSignIn") {
            return Maybe<Member>.just(Member(uid: "dummy"))
        }
        
        // when
        let isProcessings = self.waitElements(expect, for: self.viewModel.isProcessing) {
            self.viewModel.requestSignIn(OAuthServiceProviderTypes.kakao)
        }
        
        // then
        XCTAssertEqual(isProcessings, [false, true])
    }
    
    func testViewModel_whenSignInEnd_closeCurrentSceneAndEmitEvent() {
        // given
        let expect = expectation(description: "로그인 완료시에 현재 화면 닫음")
        expect.expectedFulfillmentCount = 2
        self.mockAuthUsecase.register(key: "requestSocialSignIn") {
            return Maybe<Member>.just(Member(uid: "dummy"))
        }
        
        self.viewModel.signedIn
            .subscribe(onNext: {
                expect.fulfill()
            })
            .disposed(by: self.disposeBag)
        
        self.spyRouter.called(key: "closeScene") { _ in
            expect.fulfill()
        }
        
        // when
        self.viewModel.requestSignIn(OAuthServiceProviderTypes.kakao)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testViewModel_whenSignInFail_alertError() {
        // given
        let expect = expectation(description: "로그인 실패시에 에러 알림")
        self.mockAuthUsecase.register(key: "requestSocialSignIn") {
            return Maybe<Member>.error(ApplicationErrors.invalid)
        }
        
        self.spyRouter.called(key: "alertError") { _ in
            expect.fulfill()
        }
        
        // when
        self.viewModel.requestSignIn(OAuthServiceProviderTypes.kakao)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}


extension SignInViewModelTests {
    
    class SpyRouter: SignInRouting, Mocking {
        
        func alertError(_ error: Error) {
            self.verify(key: "alertError")
        }
        
        func closeScene(animated: Bool, completed: (() -> Void)?) {
            self.verify(key: "closeScene")
            completed?()
        }
    }
}
