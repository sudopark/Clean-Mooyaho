//
//  InnerWebViewViewModelTests.swift
//  ViewerSceneTests
//
//  Created by sudo.park on 2021/10/16.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import UnitTestHelpKit
import UsecaseDoubles

import ViewerScene


class InnerWebViewViewModelTests: BaseTestCase, WaitObservableEvents, InnerWebViewRouting {
    
    var disposeBag: DisposeBag!
    var didShowError: Bool?
    var didSafariOpen: Bool?
    var didEditRequested: Bool?

    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.didShowError = nil
        self.didSafariOpen = nil
        self.didEditRequested = nil
    }
    
    private var dummyItem: ReadLink {
        return ReadLink.dummy(10)
    }
    
    func openSafariBrowser(_ address: String) {
        self.didSafariOpen = true
    }
    
    func editReadLink(_ item: ReadLink) {
        self.didEditRequested = true
    }
    
    private func makeViewModel(_ item: ReadLink,
                               preview: LinkPreview? = nil) -> InnerWebViewViewModel {
        
        let preview = preview ?? LinkPreview.dummy(0)
        let scenario = StubReadItemUsecase.Scenario()
            |> \.preview .~ .success(preview)
        let usecase = StubReadItemUsecase(scenario: scenario)
        
        return InnerWebViewViewModelImple(link: item,
                                          readItemUsecase: usecase,
                                          router: self)
    }
}


extension InnerWebViewViewModelTests {
    
    func testViewModel_whenCustomNameNotExists_showURLAddress() {
        // given
        let expect = expectation(description: "페이지 커스텀 타이 + preview title틀 없으면 url 출력")
        let item = self.dummyItem |> \.customName .~ ""
        let preview = LinkPreview(title: "", description: "some",
                                  mainImageURL: nil, iconURL: nil)
        let viewModel = self.makeViewModel(item, preview: preview)
        
        // when
        let title = self.waitFirstElement(expect, for: viewModel.urlPageTitle) {
            viewModel.prepareLinkData()
        }
        
        // then
        XCTAssertEqual(title, item.link)
    }
    
    func testViewModel_whenPrepareLinkData_udpatePageTitleByPreviewTitle() {
        // given
        let expect = expectation(description: "아이템의 프리뷰 타이틀로 업데이트")
        let item = self.dummyItem |> \.customName .~ nil
        let preview = LinkPreview(title: "preview title", description: "some",
                                  mainImageURL: nil, iconURL: nil)
        let viewModel = self.makeViewModel(item, preview: preview)
        
        // when
        let title = self.waitFirstElement(expect, for: viewModel.urlPageTitle) {
            viewModel.prepareLinkData()
        }
        
        // then
        XCTAssertEqual(title, "preview title")
    }
    
    func testViewModel_whenCustomNameExists_udpatePageTitleByCustomTitle() {
        // given
        let expect = expectation(description: "아이템의 커스텀 타이틀 존재하는경우 커스텀 타이틀로 업데이트")
        let item = self.dummyItem |> \.customName .~ "custom title"
        let preview = LinkPreview(title: "preview title", description: "some",
                                  mainImageURL: nil, iconURL: nil)
        let viewModel = self.makeViewModel(item, preview: preview)
        
        // when
        let title = self.waitFirstElement(expect, for: viewModel.urlPageTitle) {
            viewModel.prepareLinkData()
        }
        
        // then
        XCTAssertEqual(title, "custom title")
    }
    
    func testViewModel_openSafari() {
        // given
        let viewModel = self.makeViewModel(.dummy(0), preview: nil)
        
        // when
        viewModel.openPageInSafari()
        
        // then
        XCTAssert(self.didSafariOpen == true)
    }
    
    func testViewModel_editItem() {
        // given
        let viewModel = self.makeViewModel(.dummy(0), preview: nil)
        
        // when
        viewModel.editReadLink()
        
        // then
        XCTAssert(self.didEditRequested == true)
    }
    
    func testViewModel_updateIsRed() {
        // given
        let expect = expectation(description: "읽음처리 업데이트")
        expect.expectedFulfillmentCount = 3
        let viewModel = self.makeViewModel(.dummy(0), preview: nil)
        
        // when
        let isReds = self.waitElements(expect, for: viewModel.isRed) {
            viewModel.toggleMarkAsRed()
            viewModel.toggleMarkAsRed()
        }

        // then
        XCTAssertEqual(isReds, [false, true, false])
    }
}
