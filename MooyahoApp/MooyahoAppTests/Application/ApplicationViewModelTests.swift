//
//  ApplicationViewModelTests.swift
//  BreadRoadAppTests
//
//  Created by ParkHyunsoo on 2021/04/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit
import UsecaseDoubles

@testable import Readmind


class ApplicationViewModelTests: BaseTestCase, WaitObservableEvents  {
    
    var disposeBag: DisposeBag!
    var mockUsecase: MockApplicationUsecase!
    var mockShareUsecase: StubShareItemUsecase!
    var spyRouter: SpyRouter!
    var mockFirebaseService: MockFirebaseService!
    var stubFCMService: StubFCMService!
    var mockKakaoService: MockKakaoService!
    var viewModel: ApplicationViewModel!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = DisposeBag()
        self.mockUsecase = .init()
        self.mockShareUsecase = .init()
        self.spyRouter = SpyRouter()
        self.mockFirebaseService = .init()
        self.stubFCMService = .init()
        self.mockKakaoService = .init()
        self.viewModel = ApplicationViewModelImple(applicationUsecase: self.mockUsecase,
                                                   shareCollectionHandleUsecase: self.mockShareUsecase,
                                                   firebaseService: self.mockFirebaseService,
                                                   fcmService: self.stubFCMService,
                                                   kakaoService: self.mockKakaoService,
                                                   router: self.spyRouter)
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.spyRouter = nil
        self.mockFirebaseService = nil
        self.stubFCMService = nil
        self.mockKakaoService = nil
        self.mockUsecase = nil
        self.mockShareUsecase = nil
        self.viewModel = nil
        super.tearDown()
    }
    
    private func makeViewModel(_ isNotificationGranted: Bool = true) -> ApplicationViewModel {
        self.stubFCMService.isNotificationGrant = isNotificationGranted
        self.viewModel = ApplicationViewModelImple(applicationUsecase: self.mockUsecase,
                                                   shareCollectionHandleUsecase: self.mockShareUsecase,
                                                   firebaseService: self.mockFirebaseService,
                                                   fcmService: self.stubFCMService,
                                                   kakaoService: self.mockKakaoService,
                                                   router: self.spyRouter)
        return viewModel
    }
}


// MARK: - test application level routing

extension ApplicationViewModelTests {
    
    func testViewModel_whenLaunched_routeToLaunchingScene() {
        // given
        let expect = expectation(description: "론칭 이후에 론칭신으로 라우팅")
        
        self.mockUsecase.register(key: "loadLastSignInAccountInfo") {
            return Maybe<(auth: Auth, member: Member?)>.just((Auth(userID: "some"), nil))
        }
        
        self.spyRouter.called(key: "routeMain") { args in
            guard let _ = args as? Auth else { return }
            expect.fulfill()
        }
        
        // when
        self.viewModel.appDidLaunched()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testViewModel_whenAfterSignout_routeToMain() {
        // given
        let expect = expectation(description: "로그아웃되었으면 다시 메인으로 라우팅")
        
        self.spyRouter.called(key: "routeMain") { args in
            guard let auth = args as? Auth, auth.userID == "new" else { return }
            expect.fulfill()
        }
        
        // when
        self.mockUsecase.signoutSubject.onNext(.init(userID: "new"))
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}

// MARK: - test handle urls

extension ApplicationViewModelTests {
    
    func testViewModel_ifOpenURLIsKakaoURL_handleURL() {
        // given
        self.mockKakaoService.register(key: "canHandleURL") { true }
        self.mockKakaoService.register(key: "handle:url") { true }
        
        // when
        let handled = self.viewModel.handleOpenURL(url: URL(string: "dummy.url")!, options: nil)
        
        // then
        XCTAssertEqual(handled, true)
    }
    
    func testViewModel_handle_sharedCollectionURL() {
        // given
        let url = URL(string: "readminds://share/collection?id=8sQXBHiN0enSa6aIIFpP")!
        // when
        let handled = self.viewModel.handleOpenURL(url: url, options: nil)
        
        // then
        XCTAssertEqual(handled, true)
        XCTAssertNotNil(self.spyRouter.didShowSharedCollection)
    }
}


// MARK; - show remind

extension ApplicationViewModelTests {
    
    func testViewModel_whenHandleRemindMessage_showDetail() {
        // given
        let expect = expectation(description: "handle remind messsage and show")
        self.mockUsecase.register(key: "loadLastSignInAccountInfo") {
            return Maybe<(auth: Auth, member: Member?)>.just((Auth(userID: "some"), nil))
        }
        
        // when
        self.spyRouter.didShowRemindDetailRequested = {
            expect.fulfill()
        }
        self.viewModel.appDidLaunched()
        self.stubFCMService.mockPushMessages.onNext(ReadRemindMessage(itemID: "some", scheduledTime: .now()))
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testViewModel_whenHandleRemindMessageBeforeSetupInitialScene_showAfterSetupInitialScenes() {
        // given
        let expect = expectation(description: "handle remind messsage and show")
        self.mockUsecase.register(key: "loadLastSignInAccountInfo") {
            return Maybe<(auth: Auth, member: Member?)>.just((Auth(userID: "some"), nil))
        }
        
        self.spyRouter.handleRemindResult = false
        
        // when
        self.spyRouter.didShowRemindDetailRequested = {
            expect.fulfill()
        }
        self.stubFCMService.mockPushMessages.onNext(ReadRemindMessage(itemID: "some", scheduledTime: .now()))
        self.spyRouter.handleRemindResult = true
        self.viewModel.appDidLaunched()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}


extension ApplicationViewModelTests {
    
    final class SpyRouter: ApplicationRootRouting, Mocking, @unchecked Sendable {
        
        func routeMain(auth: Auth) {
            self.verify(key: "routeMain", with: auth)
        }
        
        func showNotificationAuthorizationNeedBanner() {
            self.verify(key: "showNotificationAuthorizationNeedBanner")
        }
        
        var didShowSharedCollection: SharedReadCollection?
        func showSharedReadCollection(_ collection: SharedReadCollection) {
            self.didShowSharedCollection = collection
        }
        
        var handleRemindResult: Bool = true
        var didShowRemindDetailRequested: (() -> Void)?
        func showRemindItem(_ itemID: String) -> Bool {
            let result = self.handleRemindResult
            defer {
                if result {
                    self.didShowRemindDetailRequested?()
                }
            }
            return result
        }
    }
}
