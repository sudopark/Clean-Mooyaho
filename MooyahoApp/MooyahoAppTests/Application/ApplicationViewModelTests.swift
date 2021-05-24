//
//  ApplicationViewModelTests.swift
//  BreadRoadAppTests
//
//  Created by ParkHyunsoo on 2021/04/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import UnitTestHelpKit
import StubUsecases

@testable import MooyahoApp


class ApplicationViewModelTests: BaseTestCase, WaitObservableEvents  {
    
    var disposeBag: DisposeBag!
    var stubUsecase: StubApplicationUsecase!
    var spyRouter: SpyRouter!
    var stubFirebaseService: StubFirebaseService!
    var stubKakaoService: StubKakaoService!
    var viewModel: ApplicationViewModel!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = DisposeBag()
        self.stubUsecase = .init()
        self.spyRouter = SpyRouter()
        self.stubFirebaseService = .init()
        self.stubKakaoService = .init()
        self.viewModel = ApplicationViewModelImple(applicationUsecase: self.stubUsecase,
                                                   firebaseService: self.stubFirebaseService,
                                                   kakaoService: self.stubKakaoService,
                                                   router: self.spyRouter)
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.spyRouter = nil
        self.stubFirebaseService = nil
        self.stubKakaoService = nil
        self.stubUsecase = nil
        self.viewModel = nil
        super.tearDown()
    }
}


//// MARK: - test upload user location
//
//extension ApplicationViewModelTests {
//
//    // 시작 이후에 권한 있으면 업로드
//    func testViewModel_whenAppStartAndHasLocationPermission_startUploadUserLocation() {
//        // given
//
//        // when
//        // then
//    }
//
//    // 시작 이후에 권한 없으면 업로드 안함
//
//    // 시작 이후에 권한 없음 -> 생김 -> 업로드 시작
//
//    // 시작 이후 업로드중 -> 백그라운드 진입시 중지
//
//    // 다시 포그라운드 올라왔을때 시작
//}


// MARK: - test application level routing

extension ApplicationViewModelTests {
    
    func testViewModel_whenLaunched_routeToLaunchingScene() {
        // given
        let expect = expectation(description: "론칭 이후에 론칭신으로 라우팅")
        
        self.spyRouter.called(key: "routeMain") { _ in
            expect.fulfill()
        }
        
        // when
        self.viewModel.appDidLaunched()
        
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
        
        func routeMain() {
            self.verify(key: "routeMain")
        }
    }
}
