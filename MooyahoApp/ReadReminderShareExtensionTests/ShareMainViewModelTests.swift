//
//  ShareMainViewModelTests.swift
//  ReadReminderShareExtensionTests
//
//  Created by sudo.park on 2021/12/16.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit
import UsecaseDoubles
import ReadReminderShareExtension


class ShareMainViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    private var spyRouter: SpyRouter!
    private var mockAuthUsecase: MockAuthUsecase!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.spyRouter = nil
        self.mockAuthUsecase = nil
    }
    
    private func makeViewModel() -> ShareMainViewModel {
        let router = SpyRouter()
        self.spyRouter = router
        let usecase = MockAuthUsecase()
        self.mockAuthUsecase = usecase
        return ShareMainViewModelImple(authUsecase: usecase, router: router, listener: nil)
    }
}


extension ShareMainViewModelTests {
    
    func testViewModel_prepareAuth_and_showEditScene() {
        // given
        let expect = expectation(description: "auth 준비하고 수정화면으로 이동")
        let viewModel = self.makeViewModel()
        self.mockAuthUsecase.register(key: "loadLastSignInAccountInfo") {
            return Maybe<(auth: Auth, member: Member?)>.just((Auth(userID: "some"), nil))
        }
        self.mockAuthUsecase.called(key: "loadLastSignInAccountInfo") { _ in
            expect.fulfill()
        }
        
        // when
        viewModel.showEditScene("htps://dummy-url-string")
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(self.spyRouter.didShowEditScene, true)
    }
    
    func testViewModel_whenPrepareAuthFailBeforeShowEditScene_ignoreErrorAndRoute() {
        // given
        let expect = expectation(description: "auth 준비시에 에러발생하면 무시하고 수정화면으로 이동")
        let viewModel = self.makeViewModel()
        self.mockAuthUsecase.register(key: "loadLastSignInAccountInfo") {
            return Maybe<(auth: Auth, member: Member?)>.error(ApplicationErrors.invalid)
        }
        self.mockAuthUsecase.called(key: "loadLastSignInAccountInfo") { _ in
            expect.fulfill()
        }
        
        // when
        viewModel.showEditScene("htps://dummy-url-string")
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(self.spyRouter.didShowEditScene, true)
    }
}


extension ShareMainViewModelTests {
    
    class SpyRouter: ShareMainRouting {
        var didShowEditScene: Bool?
        func showEditScene(_ url: String) {
            self.didShowEditScene = true
        }
    }
}
