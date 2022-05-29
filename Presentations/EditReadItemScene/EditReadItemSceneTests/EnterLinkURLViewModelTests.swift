//
//  EnterLinkURLViewModelTests.swift
//  EditReadItemSceneTests
//
//  Created by sudo.park on 2021/10/03.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit
import UsecaseDoubles

import EditReadItemScene


class EnterLinkURLViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var isURLEntered: ((String) -> Void)?
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.isURLEntered = nil
        self.disposeBag = nil
    }
    
    private func makeViewModel(_ startWith: String? = nil) -> EnterLinkURLViewModel {
        
        return EnterLinkURLViewModelImple(startWith: startWith, router: self) {
            self.isURLEntered?($0)
        }
    }
}


extension EnterLinkURLViewModelTests {
    
    func testViewModel_whenEnterValidURLAddress_updateConfirmButton() {
        // given
        let expect = expectation(description: "유효한 url 입력시에 확인버튼 활성화")
        expect.expectedFulfillmentCount = 3
        let viewModel = self.makeViewModel()
        
        // when
        let isEnableds = self.waitElements(expect, for: viewModel.isConfirmable) {
            viewModel.enterURL("https://www.naver.com")
            viewModel.enterURL("wrong")
        }
        
        // then
        XCTAssertEqual(isEnableds, [false, true, false])
    }
    
    func testViewModel_whenAfterConfirmEnterURL_moveToConfirmAddScene() {
        // given
        let expect = expectation(description: "url 입력 확인")
        let viewModel = self.makeViewModel()
        
        self.isURLEntered = { _ in
            expect.fulfill()
        }
        
        // when
        viewModel.enterURL("https://www.naver.com")
        viewModel.confirmEnter()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testViewModel_whenTryToConfirmEnterURL_trimWhiteSpaceAndNewLine() {
        // given
        let expect = expectation(description: "입력 확인시에 공백 등 trim")
        let viewModel = self.makeViewModel()
        var confirmedURL: String?
        
        self.isURLEntered = { entered in
            confirmedURL = entered
            expect.fulfill()
        }
        
        // when
        let validAddress = "https://www.naver.com"
        let addressWithWhiteSpace = "  \n \(validAddress) \n   \n"
        viewModel.enterURL(addressWithWhiteSpace)
        viewModel.confirmEnter()
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(confirmedURL, validAddress)
    }
    
    func testViewModel_whenStartWithURLExists_updateURLAndRouteToNext() {
        // given
        let expect = expectation(description: "start with url 존재시 바로 다음화면으로 이동")
        let viewModel = self.makeViewModel("some")
        
        self.isURLEntered = { _ in
            expect.fulfill()
        }
        
        // when
        viewModel.startAutoEnterURLIfNeed()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}


extension EnterLinkURLViewModelTests: EnterLinkURLRouting { }
