//
//  ShareMainViewModelTests.swift
//  ReadReminderShareExtensionTests
//
//  Created by sudo.park on 2021/12/16.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import UnitTestHelpKit
import UsecaseDoubles
import ReadReminderShareExtension


class ShareMainViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    private var spyRouter: SpyRouter!
    private var mockAuthUsecase: MockAuthUsecase!
    private var spyReadItemUsecase: StubReadItemUsecase!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.spyRouter = nil
        self.mockAuthUsecase = nil
        self.spyReadItemUsecase = nil
    }
    
    private func makeViewModel() -> ShareMainViewModelImple {
        let router = SpyRouter()
        self.spyRouter = router
        let authUsecase = MockAuthUsecase()
        self.mockAuthUsecase = authUsecase
        
        let syncUsecase = StubReadItemUsecase()
        self.spyReadItemUsecase = syncUsecase
        
        return ShareMainViewModelImple(authUsecase: authUsecase,
                                       readItemSyncUsecase: syncUsecase,
                                       router: router,
                                       listener: nil)
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
    
    func testViewModel_whenAfterAddItem_updateIsReloadNeed() {
        // given
        let viewModel = self.makeViewModel()
        self.mockAuthUsecase.register(key: "loadLastSignInAccountInfo") {
            return Maybe<(auth: Auth, member: Member?)>.just((Auth(userID: "some"), nil))
        }
        
        // when + then
        viewModel.showEditScene("https://dummy-url")
        
        let dummy1 = ReadLink.dummy(0); let dummy2 = dummy1 |> \.parentID .~ "some"
        
        viewModel.editReadLink(didEdit: dummy1)
        XCTAssertEqual(self.spyReadItemUsecase.reloadNeedCollectionIDs, [ReadCollection.rootID])
        
        viewModel.editReadLink(didEdit: dummy2)
        XCTAssertEqual(self.spyReadItemUsecase.reloadNeedCollectionIDs, [ReadCollection.rootID, "some"])
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
