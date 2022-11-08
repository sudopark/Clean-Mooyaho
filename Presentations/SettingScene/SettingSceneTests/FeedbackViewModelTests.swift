//
//  FeedbackViewModelTests.swift
//  SettingSceneTests
//
//  Created by sudo.park on 2021/12/15.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit
import UsecaseDoubles

import SettingScene


class FeedbackViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var spyRouter: SpyRouter!
    private var viewModelRef: FeedbackViewModel?
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.spyRouter = nil
        self.viewModelRef = nil
    }
    
    private func makeViewModel() -> FeedbackViewModel {
        
        let usecase = StubFeedbackUsecase()
        let router = SpyRouter()
        self.spyRouter = router
        let viewModel = FeedbackViewModelImple(
            feedbackUsecase: usecase,
            router: router,
            listener: nil
        )
        self.viewModelRef = viewModel
        return viewModel
    }
}


extension FeedbackViewModelTests {
    
    func testViewModel_whenValidMessageAndEmailEntered_isConfirmable() {
        // given
        let expect = expectation(description: "메세지, 이메일 입력이 유요할경우에 등록 가능함")
        expect.expectedFulfillmentCount = 3
        let viewModel = self.makeViewModel()
        
        // when
        let isEnables = self.waitElements(expect, for: viewModel.isConfirmable) {
            viewModel.enterMessage("some")
            viewModel.enterContact("invalid")
            viewModel.enterContact("valid@email.com")
            viewModel.enterMessage("")
        }
        
        // then
        XCTAssertEqual(isEnables, [false, true, false])
    }
    
    func testViewMdoel_registerFeedbackAndFinishScene() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.enterMessage("some")
        viewModel.enterContact("valid@email.com")
        viewModel.register()
        
        // then
        XCTAssertEqual(self.spyRouter.didClsoe, true)
    }
}

extension FeedbackViewModelTests {
    
    final class SpyRouter: FeedbackRouting, @unchecked Sendable {
        
        var didClsoe: Bool?
        func closeScene(animated: Bool, completed: (() -> Void)?) {
            self.didClsoe = true
            completed?()
        }
    }
}
