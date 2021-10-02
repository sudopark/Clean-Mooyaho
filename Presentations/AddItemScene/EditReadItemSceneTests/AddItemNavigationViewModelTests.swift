//
//  AddItemNavigationViewModelTests.swift
//  EditReadItemSceneTests
//
//  Created by sudo.park on 2021/10/02.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit
import UsecaseDoubles

import EditReadItemScene


class AddItemNavigationViewModelTests: BaseTestCase {
    
    private var didNavigationSetup: Bool?
    private var didMoveToEnterURLScene: Bool?
    private var didMoveToConfirmAdd: Bool?
    private var didClosed: Bool?
    private var enterURLMocking: ((String) -> Void)?
    private var confirmAddNewMockding: ((ReadLink) -> Void)?
    
    override func tearDownWithError() throws {
        self.didNavigationSetup = nil
        self.didMoveToEnterURLScene = nil
        self.didMoveToConfirmAdd = nil
        self.didClosed = nil
        self.enterURLMocking = nil
    }
    
    private func makeViewModel(_ completed: ((ReadLink) -> Void)? = nil) -> AddItemNavigationViewModel {
        
        return AddItemNavigationViewModelImple(targetCollectionID: nil,
                                               router: self, completed ?? { _ in })
    }
}

extension AddItemNavigationViewModelTests {
    
    
    func testViewModel_prepareNavigation() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.prepareNavigation()
        
        // then
        XCTAssertEqual(self.didNavigationSetup, true)
    }
    
    func testViewModel_whenAfterprepareNavigation_moveToEnterURLScene() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.prepareNavigation()
        
        // then
        XCTAssertEqual(self.didMoveToEnterURLScene, true)
    }
    
    func testViewMdoeL_whenAfterEnterURLEnd_moveToAddnewItemScene() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.prepareNavigation()
        self.enterURLMocking?("https://wwww.dummy_url.com")
        
        // then
        XCTAssertEqual(self.didMoveToConfirmAdd, true)
    }
    
    func testViewModel_whenAfterAddIteMConfirmCompleted_closeAndEmitNewItem() {
        // given
        let expect = expectation(description: "아이템 추가 확인 완료 이후에 화면 닫고 외부로 이벤트 전파")
        let viewModel = self.makeViewModel { _ in
            expect.fulfill()
        }
        
        // when
        viewModel.prepareNavigation()
        self.enterURLMocking?("https://wwww.dummy_url.com")
        self.confirmAddNewMockding?(.dummy(0))
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(self.didClosed, true)
    }
}


extension AddItemNavigationViewModelTests: AddItemNavigationRouting {
    
    func prepareNavigation() {
        self.didNavigationSetup = true
    }
    
    func pushToEnterURLScene(_ entered: @escaping (String) -> Void) {
        self.didMoveToEnterURLScene = true
        self.enterURLMocking = { entered($0) }
    }
    
    func pushConfirmAddLinkItemScene(at collectionID: String?,
                                     url: String,
                                     _ completed: @escaping (ReadLink) -> Void) {
        self.didMoveToConfirmAdd = true
        self.confirmAddNewMockding = { completed($0) }
    }
    
    func closeScene(animated: Bool, completed: (() -> Void)?) {
        self.didClosed = true
        completed?()
    }
}
