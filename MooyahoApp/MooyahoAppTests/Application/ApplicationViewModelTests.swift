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
import StubUsecases

@testable import MooyahoApp


class ApplicationViewModelTests: BaseTestCase, WaitObservableEvents  {
    
    var disposeBag: DisposeBag!
    var stubUsecase: StubApplicationUsecase!
    var spyRouter: SpyRouter!
    var stubFirebaseService: StubFirebaseService!
    var stubFCMService: StubFCMService!
    var stubKakaoService: StubKakaoService!
    var viewModel: ApplicationViewModel!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = DisposeBag()
        self.stubUsecase = .init()
        self.spyRouter = SpyRouter()
        self.stubFirebaseService = .init()
        self.stubFCMService = .init()
        self.stubKakaoService = .init()
        self.viewModel = ApplicationViewModelImple(applicationUsecase: self.stubUsecase,
                                                   firebaseService: self.stubFirebaseService,
                                                   fcmService: self.stubFCMService,
                                                   kakaoService: self.stubKakaoService,
                                                   router: self.spyRouter)
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.spyRouter = nil
        self.stubFirebaseService = nil
        self.stubFCMService = nil
        self.stubKakaoService = nil
        self.stubUsecase = nil
        self.viewModel = nil
        super.tearDown()
    }
    
    private func makeViewModel(_ isNotificationGranted: Bool = true) -> ApplicationViewModel {
        self.stubFCMService.isNotificationGrant = isNotificationGranted
        self.viewModel = ApplicationViewModelImple(applicationUsecase: self.stubUsecase,
                                                   firebaseService: self.stubFirebaseService,
                                                   fcmService: self.stubFCMService,
                                                   kakaoService: self.stubKakaoService,
                                                   router: self.spyRouter)
        return viewModel
    }
}


// MARK: - test application level routing

extension ApplicationViewModelTests {
    
    func testViewModel_whenLaunched_routeToLaunchingScene() {
        // given
        let expect = expectation(description: "론칭 이후에 론칭신으로 라우팅")
        
        self.stubUsecase.register(key: "loadLastSignInAccountInfo") {
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
}

// MARK: - test notification

extension ApplicationViewModelTests {
    
    func testViewModel_whenRequestNotificationAuthorizationAndDenied_showGrantNeedBanner() {
        // given
        let expect = expectation(description: "앱 론칭 이후에 알림권한없으면 필요 배너 알림")
        let _ = self.makeViewModel(false)
        
        self.spyRouter.called(key: "showNotificationAuthorizationNeedBanner") { _ in
            expect.fulfill()
        }
        // when
        self.stubFCMService.checkIsGranted()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}


// MARK: - test handle urls

extension ApplicationViewModelTests {
    
    func testViewModel_ifOpenURLIsKakaoURL_handleURL() {
        // given
        self.stubKakaoService.register(key: "canHandleURL") { true }
        self.stubKakaoService.register(key: "handle:url") { true }
        
        // when
        let handled = self.viewModel.handleOpenURL(url: URL(string: "dummy.url")!, options: nil)
        
        // then
        XCTAssertEqual(handled, true)
    }
}


extension ApplicationViewModelTests {
    
    class SpyRouter: ApplicationRootRouting, Stubbable {
        
        func routeMain(auth: Auth) {
            self.verify(key: "routeMain", with: auth)
        }
        
        func showNotificationAuthorizationNeedBanner() {
            self.verify(key: "showNotificationAuthorizationNeedBanner")
        }
    }
}
