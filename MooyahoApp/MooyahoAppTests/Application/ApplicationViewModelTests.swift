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
    var viewModel: ApplicationViewModel!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = DisposeBag()
        self.spyRouter = SpyRouter()
        self.viewModel = ApplicationViewModel(router: self.spyRouter)
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.spyRouter = nil
        self.viewModel = nil
        super.tearDown()
    }
}


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



extension ApplicationViewModelTests {
    
    class SpyRouter: ApplicationRootRouting, Stubbable {
        
        func routeMain() {
            self.verify(key: "routeMain")
        }
    }
}
