//
//  EnterHoorayMessageViewModelTests.swift
//  HooraySceneTests
//
//  Created by sudo.park on 2021/06/07.
//

import XCTest

import RxSwift

import Domain
import CommonPresenting
import UnitTestHelpKit
import StubUsecases

@testable import HoorayScene


class EnterHoorayMessageViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var spyRouter: SpyRouter!
    var viewModel: EnterHoorayMessageViewModelImple!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.spyRouter = .init()
        self.viewModel = .init(form: .init(publisherID: "some"),
                               selectedImagePath: nil,
                               router: self.spyRouter)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.spyRouter = nil
        self.viewModel = nil
    }
}


extension EnterHoorayMessageViewModelTests {
    
    func testViewModel_previousInputMessage_isInitialMessage() {
        // given
        let previousForm = NewHoorayForm(publisherID: "some")
        previousForm.message = "previous"
        self.viewModel = .init(form: previousForm, selectedImagePath: nil, router: self.spyRouter)
        
        // when
        let initialMessage = self.viewModel.previousInputText
        
        // then
        XCTAssertEqual(initialMessage, "previous")
    }
    
    func testViewModel_whenEnteringText_updateNextButtonEnabled() {
        // given
        let expect = expectation(description: "텍스트 입력 여부에 따라 다음버튼 업데이트")
        expect.expectedFulfillmentCount = 3
        
        // when
        let isEnableds = self.waitElements(expect, for: self.viewModel.isNextButtonEnabled) {
            self.viewModel.updateText("some")
            self.viewModel.updateText("")
        }
        
        // then
        XCTAssertEqual(isEnableds, [false, true, false])
    }
    
    func testViewModel_goNextInputStage() {
        // given
        let expect = expectation(description: "다음 입력 화면으로 이동")
        
        self.spyRouter.called(key: "presentNextInputStage") { _ in
            expect.fulfill()
        }
        
        // when
        self.viewModel.updateText("some")
        self.viewModel.goNextInputStage()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}

extension EnterHoorayMessageViewModelTests {
    
    class SpyRouter: EnterHoorayMessageRouting, Stubbable {
        
        func presentNextInputStage(_ form: NewHoorayForm, selectedImage: String?) {
            self.verify(key: "presentNextInputStage")
        }
    }
}
