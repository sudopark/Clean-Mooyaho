//
//  LinkMemoViewModelTests.swift
//  ViewerSceneTests
//
//  Created by sudo.park on 2021/10/24.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import CommonPresenting
import UnitTestHelpKit
import UsecaseDoubles

import ViewerScene


class LinkMemoViewModelTests: BaseTestCase, WaitObservableEvents, LinkMemoRouting, LinkMemoSceneListenable {
    
    var disposeBag: DisposeBag!
    var didClose: Bool?
    var didUpdatedMemo: ReadLinkMemo?
    var didRemovedMemoItemID: String?
    
    func closeScene(animated: Bool, completed: (() -> Void)?) {
        self.didClose = true
        completed?()
    }
    
    func linkMemo(didUpdated newVlaue: ReadLinkMemo) {
        self.didUpdatedMemo = newVlaue
    }
    
    func linkMemo(didRemoved linkItemID: String) {
        self.didRemovedMemoItemID = linkItemID
    }
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.didClose = nil
        self.didUpdatedMemo = nil
        self.didRemovedMemoItemID = nil
    }
    
    private func makeViewModel() -> LinkMemoViewModel {
        
        let usecase = StubMemoUsecase()
        return LinkMemoViewModelImple(memo: .init(itemID: "some"),
                                      memoUsecase: usecase,
                                      router: self, listener: self)
    }
}

extension LinkMemoViewModelTests {
    
    func testViewModel_udpateSavable_byContentUpdating() {
        // given
        let expect = expectation(description: "컨텐츠 입력에따라 저장가능여부 업데이트")
        expect.expectedFulfillmentCount = 3
        let viewModel = self.makeViewModel()
        
        // when
        let isSavable = self.waitElements(expect, for: viewModel.confirmSavable) {
            viewModel.updateContent("some")
            viewModel.updateContent("")
        }
        
        // then
        XCTAssertEqual(isSavable, [false, true, false])
    }
    
    func testViewModel_deleteMemo() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.deleteMemo()
        
        // then
        XCTAssertEqual(self.didClose, true)
        XCTAssertEqual(self.didRemovedMemoItemID, "some")
    }
    
    func testViewModel_updateMemo() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.updateContent("some value")
        viewModel.confirmSave()
        
        // then
        XCTAssertEqual(self.didClose, true)
        XCTAssertEqual(self.didUpdatedMemo?.content, "some value")
    }
}
