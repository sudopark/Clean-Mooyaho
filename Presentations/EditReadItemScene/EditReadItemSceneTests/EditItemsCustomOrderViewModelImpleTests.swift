//
//  EditItemsCustomOrderViewModelImpleTests.swift
//  EditReadItemSceneTests
//
//  Created by sudo.park on 2021/10/15.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import CommonPresenting
import UnitTestHelpKit
import UsecaseDoubles

@testable import EditReadItemScene


class EditItemsCustomOrderViewModelImpleTests: BaseTestCase, WaitObservableEvents, EditItemsCustomOrderRouting {
    
    var disposeBag: DisposeBag!
    var didClose: Bool?
    var didAlertError: Bool?
    private var spyUsecase: SpyUsecase?
    
    func closeScene(animated: Bool, completed: (() -> Void)?) {
        self.didClose = true
    }
    
    func alertError(_ error: Error) {
        self.didAlertError = true
    }
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.didClose = nil
        self.didAlertError = nil
        self.spyUsecase = nil
    }
    
    private var dummySubCollections: [ReadCollection] {
        return (0..<5).map { int -> ReadCollection in
            return ReadCollection.dummy(int)
        }
    }
    
    private var dummySubLinks: [ReadLink] {
        return (5..<10).map { int -> ReadLink in
            return ReadLink.dummy(int)
        }
    }
    
    private var dummyPreviousCustomOrder: [String] {
        ["c:2", "c:1", "c:0", "c:4", "c:3", "l:9", "l:6", "l:7", "l:8", "l:5"]
    }
    
    private func makeViewModel(isRoot: Bool = false,
                               noSubCollection: Bool = false,
                               shouldFailToSave: Bool = false) -> EditItemsCustomOrderViewModel {
        
        let items: [ReadItem] = (noSubCollection ? [] : self.dummySubCollections) + self.dummySubLinks
        let scenario = StubReadItemUsecase.Scenario()
            |> \.customOrder .~ .success(self.dummyPreviousCustomOrder)
            |> \.collectionItems .~ .success(items)
            |> \.updateCustomOrderResult .~ (shouldFailToSave ? .failure(ApplicationErrors.invalid) : .success(()))
        let usecase = SpyUsecase(scenario: scenario)
        self.spyUsecase = usecase
        
        return EditItemsCustomOrderViewModelImple(collectionID: isRoot ? nil : "some",
                                                  readItemUsecase: usecase,
                                                  router: self, listener: nil)
    }
}


extension EditItemsCustomOrderViewModelImpleTests {
    
    // ????????? ????????? ????????? ????????? ??????
    func testViewModel_showItemsWithCurrentCustomOrder() {
        // given
        let expect = expectation(description: "????????? ?????? ????????? ????????? ?????? ????????? ??????")
        let viewModel = self.makeViewModel()
        
        // when
        let sections = self.waitFirstElement(expect, for: viewModel.sections) {
            viewModel.loadCollectionItemsWithCustomOrder()
        }
        
        // then
        let ids = sections?.flatMap { $0.cellViewModels.map { $0.uid } }
        XCTAssertEqual(ids, ["c:2", "c:1", "c:0", "c:4", "c:3", "l:9", "l:6", "l:7", "l:8", "l:5"])
    }
    
    // ???????????? ?????????????????? ?????? ?????? ??????
    func testViewModel_reorderCollectionItems() {
        // given
        let expect = expectation(description: "????????? ????????? ?????? ??????")
        let viewModel = self.makeViewModel()
        
        // when
        let sections = self.waitFirstElement(expect, for: viewModel.sections, skip: 1) {
            viewModel.loadCollectionItemsWithCustomOrder()
            let (from, to) = (IndexPath(row: 0, section: 0), IndexPath(row: 2, section: 0))
            viewModel.itemMoved(from: from, to: to)
        }
        
        // then
        let ids = sections?.flatMap { $0.cellViewModels.map { $0.uid } }
        XCTAssertEqual(ids, ["c:1", "c:0", "c:2", "c:4", "c:3", "l:9", "l:6", "l:7", "l:8", "l:5"])
    }
    
    // ???????????? ????????? ????????? ???????????? ??????
    func testViewModel_reorderLinkItems() {
        // given
        let expect = expectation(description: "?????? ????????? ?????? ??????")
        let viewModel = self.makeViewModel()
        
        // when
        let sections = self.waitFirstElement(expect, for: viewModel.sections, skip: 1) {
            viewModel.loadCollectionItemsWithCustomOrder()
            let (from, to) = (IndexPath(row: 0, section: 1), IndexPath(row: 2, section: 1))
            viewModel.itemMoved(from: from, to: to)
        }
        
        // then
        let ids = sections?.flatMap { $0.cellViewModels.map { $0.uid } }
        XCTAssertEqual(ids, ["c:2", "c:1", "c:0", "c:4", "c:3", "l:6", "l:7", "l:9", "l:8", "l:5"])
    }
    
    // ???????????? ????????? ????????? ???????????? ??????
    func testViewModel_whenOnlyLinkExists_reorderLinkItemsAtFirstSection() {
        // given
        let expect = expectation(description: "????????? ???????????? ????????? ?????? ??????")
        let viewModel = self.makeViewModel(noSubCollection: true)
        
        // when
        let sections = self.waitFirstElement(expect, for: viewModel.sections, skip: 1) {
            viewModel.loadCollectionItemsWithCustomOrder()
            let (from, to) = (IndexPath(row: 0, section: 0), IndexPath(row: 2, section: 0))
            viewModel.itemMoved(from: from, to: to)
        }
        
        // then
        let ids = sections?.flatMap { $0.cellViewModels.map { $0.uid } }
        XCTAssertEqual(ids, ["l:6", "l:7", "l:9", "l:8", "l:5"])
    }
}

extension EditItemsCustomOrderViewModelImpleTests {
    
    // ???????????? ????????? ???????????? ????????? ????????? ??????(??? ???????????????)
    func testViewModel_whenAfterSaveOrder_close() {
        // given
        let expect = expectation(description: "????????? ???????????? ?????? ??????")
        let viewModel = self.makeViewModel()

        let _ = self.waitFirstElement(expect, for: viewModel.sections, skip: 1) {
            viewModel.loadCollectionItemsWithCustomOrder()
            let (from, to) = (IndexPath(row: 0, section: 0), IndexPath(row: 2, section: 0))
            viewModel.itemMoved(from: from, to: to)
        }

        // when
        viewModel.confirmSave()

        // then
        XCTAssertEqual(self.didClose, true)
        XCTAssertEqual(self.spyUsecase?.didUpdatedCustomorder?.0, "some")
        XCTAssertEqual(self.spyUsecase?.didUpdatedCustomorder?.1, ["c:1", "c:0", "c:2", "c:4", "c:3", "l:9", "l:6", "l:7", "l:8", "l:5"])
    }

    // ??????????????? ??????
    func testViewModel_whenAfterSaveOrderFail_alertError() {
        // given
        let expect = expectation(description: "????????? ??????????????? ?????? ??????")
        let viewModel = self.makeViewModel(shouldFailToSave: true)

        let _ = self.waitFirstElement(expect, for: viewModel.sections, skip: 1) {
            viewModel.loadCollectionItemsWithCustomOrder()
            let (from, to) = (IndexPath(row: 0, section: 0), IndexPath(row: 2, section: 0))
            viewModel.itemMoved(from: from, to: to)
        }

        // when
        viewModel.confirmSave()

        // then
        XCTAssertEqual(self.didAlertError, true)
    }
}


private extension EditItemsCustomOrderViewModelImpleTests {
    
    final class SpyUsecase: StubReadItemUsecase {
        
        var didUpdatedCustomorder: (String, [String])?
        
        override func updateCustomOrder(for collectionID: String, itemIDs: [String]) -> Maybe<Void> {
            self.didUpdatedCustomorder = (collectionID, itemIDs)
            return super.updateCustomOrder(for: collectionID, itemIDs: itemIDs)
        }
    }
}
