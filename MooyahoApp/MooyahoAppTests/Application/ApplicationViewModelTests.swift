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

@testable import MooyahoApp


class ApplicationViewModelTests: BaseTestCase, WaitObservableEvents  {
    
    var disposeBag: DisposeBag!
    var spyRouter: SpyRouter!
    var stubFirebaseService: StubFirebaseService!
    var stubKakaoService: StubKakaoService!
    var viewModel: ApplicationViewModel!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = DisposeBag()
        self.spyRouter = SpyRouter()
        self.stubFirebaseService = .init()
        self.stubKakaoService = .init()
        self.viewModel = ApplicationViewModel(firebaseService: self.stubFirebaseService,
                                              kakaoService: self.stubKakaoService,
                                              router: self.spyRouter)
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.spyRouter = nil
        self.stubFirebaseService = nil
        self.stubKakaoService = nil
        self.viewModel = nil
        super.tearDown()
    }
}


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
