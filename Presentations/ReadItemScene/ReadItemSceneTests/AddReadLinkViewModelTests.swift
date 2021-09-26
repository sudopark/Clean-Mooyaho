//
//  AddReadLinkViewModelTests.swift
//  ReadItemSceneTests
//
//  Created by sudo.park on 2021/09/26.
//

import XCTest

import RxSwift

import Domain
import Prelude
import Optics
import UnitTestHelpKit
import UsecaseDoubles

import ReadItemScene


class AddReadLinkViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var spyRouter: FakeRouter!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
    }
    
    private func makeViewModel(collectionID: String? = nil,
                               shouldFailLoadPreview: Bool = false,
                               shouldfailAddItem: Bool = false,
                               callback: (() -> Void)? = nil) -> AddReadLinkViewModel {

        let scenario = StubReadItemUsecase.Scenario()
            |> \.updateLinkResult .~ ( shouldfailAddItem ? .failure(ApplicationErrors.invalid) : .success(()) )
        let usecaseStub = PrivateStubReadItemUsecase(scenario: scenario)
        usecaseStub.alwaysFailLoadPreview = shouldFailLoadPreview
        
        let router = FakeRouter()
        self.spyRouter = router
        
        return AddReadLinkViewModelImple(collectionID: collectionID,
                                         readItemUsecase: usecaseStub,
                                         router: router,
                                         itemAddded: callback)
    }
}


extension AddReadLinkViewModelTests {
    
    func testViewModel_whenEnterLink_showPreview() {
        // given
        let expect = expectation(description: "추가할 링크 입력시에 프리뷰 노출")
        let viewModel = self.makeViewModel()
        
        // when
        let enteredPreview = self.waitFirstElement(expect, for: viewModel.enteredLinkPreview) {
            viewModel.enterURL("")
            viewModel.enterURLFinished()
            viewModel.enterURL("https://www.google.com")
            viewModel.enterURLFinished()
        }
        
        // then
        XCTAssertNotNil(enteredPreview?.preview)
    }
    
    func testViewModel_whenPreviewIsEmpty_updateNil() {
        // given
        let expect = expectation(description: "preview 없을경우에 없다고 알림")
        let viewModel = self.makeViewModel(shouldFailLoadPreview: true)
        
        // when
        let enteredPreview = self.waitFirstElement(expect, for: viewModel.enteredLinkPreview) {
            viewModel.enterURL("https://www.google.com")
            viewModel.enterURLFinished()
        }
        
        // then
        if case .notExist = enteredPreview {
            XCTAssert(true)
        } else {
            XCTFail("올바른 값이 아님")
        }
    }
    
    func testViewModel_updateIsConfirmableByEnteredURL() {
        // given
        let expect = expectation(description: "입력한 url에 따라 저장가능여부 업데이트")
        expect.expectedFulfillmentCount = 3
        let viewModel = self.makeViewModel()
        
        // when
        let isConfirmables = self.waitElements(expect, for: viewModel.isConfirmable) {
            viewModel.enterURL("https://www.google.com")
            viewModel.enterURL("adsdads")
        }
        
        // then
        XCTAssertEqual(isConfirmables, [false, true, false])
    }
    
    func testViewModel_whenPrepareEnteredLinkPreview_showLoading() {
        // given
        let expect = expectation(description: "preview 로딩표시")
        expect.expectedFulfillmentCount = 2
        let viewModel = self.makeViewModel()
        
        // when
        let isLoading = self.waitElements(expect, for: viewModel.isLoadingPreview) {
            viewModel.enterURL("https://www.google.com")
            viewModel.enterURLFinished()
        }
        
        // then
        XCTAssertEqual(isLoading, [true, false])
    }
    
    func testViewModel_saveLink() {
        // given
        let expect = expectation(description: "link 아이템 추가")
        var itemAdded: Bool = false
        let viewModel = self.makeViewModel {
            itemAdded = true
            expect.fulfill()
        }
        
        // when
        viewModel.enterURL("https://www.google.com")
        viewModel.enterURLFinished()
        viewModel.saveLink()
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(itemAdded, true)
        XCTAssertEqual(self.spyRouter.sceneClosed, true)
    }
    
    func testViewMdoel_whenSaveLinkFail_showError() {
        // given
        let expect = expectation(description: "아이템 추가 실패")
        let viewModel = self.makeViewModel(shouldfailAddItem: true)
        
        self.spyRouter.showError = { _ in
            expect.fulfill()
        }
        // when
        viewModel.enterURL("https://www.google.com")
        viewModel.enterURLFinished()
        viewModel.saveLink()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testViewModel_whenSaveLink_showLoading() {
        // given
        let expect = expectation(description: "아이템 추가중에는 로딩 표시")
        expect.expectedFulfillmentCount = 2
        let viewModel = self.makeViewModel()
        
        // when
        let isSavings = self.waitElements(expect, for: viewModel.isSavingLinkItem) {
            viewModel.enterURL("https://www.google.com")
            viewModel.enterURLFinished()
            viewModel.saveLink()
        }
        
        // then
        XCTAssertEqual(isSavings, [true, false])
    }
}


extension AddReadLinkViewModelTests {
    
    class FakeRouter: AddReadLinkRouting {
        
        var sceneClosed: Bool = false
        var showError: ((Error) -> Void)?
        
        func alertError(_ error: Error) {
            self.showError?(error)
        }
        
        func closeScene(animated: Bool, completed: (() -> Void)?) {
            self.sceneClosed = true
            completed?()
        }
    }
    
    class PrivateStubReadItemUsecase: StubReadItemUsecase {
        
        var alwaysFailLoadPreview = false
        
        override func loadLinkPreview(_ url: String) -> Observable<LinkPreview> {
            guard self.alwaysFailLoadPreview == false,
                  URL(string: url) != nil else {
                      
                return .error(ApplicationErrors.invalid)
            }
            return .just(LinkPreview.dummy(0))
        }
    }
}

