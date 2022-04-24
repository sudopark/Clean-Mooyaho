//
//  EditReadPriorityViewModelTests.swift
//  EditReadItemSceneTests
//
//  Created by sudo.park on 2021/10/05.
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


class TestEditReadPriorityViewModelImple: BaseEditReadPriorityViewModelImple {
    
    let underLyingStartWith: ReadPriority?
    init(start: ReadPriority?, router: EditReadPriorityRouting) {
        self.underLyingStartWith = start
        super.init(router: router, listener: nil)
    }
    
    override var startWithSelect: ReadPriority? { self.underLyingStartWith }
}

class EditReadPriorityViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var didClose: Bool?
    var didAlertPresented: Bool?
    var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.didClose = nil
        self.didAlertPresented = nil
    }
    
    func makeViewModel(start: ReadPriority? = nil) -> BaseEditReadPriorityViewModelImple {
        
        return TestEditReadPriorityViewModelImple(start: start, router: self)
    }
}


extension EditReadPriorityViewModelTests {
    
    func testViewModel_showPriorities_withOrder() {
        // given
        let expect = expectation(description: "우선순위 목록 노출시에 높은것부터 노출")
        let viewModel = self.makeViewModel()
        
        // when
        let cellViewModels = self.waitFirstElement(expect, for: viewModel.cellViewModels) {
            viewModel.showPriorities()
        }
        
        // then
        let allCasesRawValues = ReadPriority.allCases.map { $0.rawValue }.sorted(by: { $0 > $1 })
        XCTAssertEqual(cellViewModels?.map{ $0.rawValue }, allCasesRawValues )
    }
    
    func testViewMdoel_showPriority_withPreviousSelected() {
        // given
        let expect = expectation(description: "우선순위 목록 노출시에 이전에 선택한 값과 함께 노출")
        let viewModel = self.makeViewModel(start: .someDay)
        
        // when
        let cellViewModels = self.waitFirstElement(expect, for: viewModel.cellViewModels) {
            viewModel.showPriorities()
        }
        
        // then
        let selectedCell = cellViewModels?.filter { $0.isSelected }
        let selectedValue = selectedCell?.first?.rawValue
        XCTAssertEqual(selectedCell?.count, 1)
        XCTAssertEqual(selectedValue, ReadPriority.someDay.rawValue)
    }
    
    func testViewModel_selectPriority() {
        // given
        let expect = expectation(description: "우선순위 선택")
        expect.expectedFulfillmentCount = 3
        let viewModel = self.makeViewModel(start: .someDay)
        
        // when
        let cellViewModelLists = self.waitElements(expect, for: viewModel.cellViewModels) {
            viewModel.showPriorities()
            viewModel.selectPriority(ReadPriority.someDay.rawValue)
            viewModel.selectPriority(ReadPriority.beforeDying.rawValue)
            viewModel.selectPriority(ReadPriority.beforeDying.rawValue)
            viewModel.selectPriority(ReadPriority.someDay.rawValue)
        }
        
        // then
        let selectedValues = cellViewModelLists.map { $0.first(where: { $0.isSelected })?.rawValue }
        XCTAssertEqual(selectedValues, [
            ReadPriority.someDay.rawValue,
            ReadPriority.beforeDying.rawValue,
            ReadPriority.someDay.rawValue
        ])
    }
}

extension EditReadPriorityViewModelTests: EditReadPriorityRouting {
    
    func closeScene(animated: Bool, completed: (() -> Void)?) {
        self.didClose = true
        completed?()
    }
    
    func alertError(_ error: Error) {
        self.didAlertPresented = true
    }
}



// MARK: - EditReadPriorityViewModelTests_select

class EditReadPriorityViewModelTests_select: EditReadPriorityViewModelTests, ReadPrioritySelectListenable {
    
    var didSelectedPriority: ReadPriority?
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        self.didSelectedPriority = nil
    }
    
    override func makeViewModel(start: ReadPriority? = nil) -> BaseEditReadPriorityViewModelImple {
        return ReadPrioritySelectViewModelImple(startWithSelect: start, router: self, listener: self)
    }
    
    func editReadPriority(didSelect priority: ReadPriority) {
        self.didSelectedPriority = priority
    }
}


extension EditReadPriorityViewModelTests_select {
    
    func testViewModel_whenConfirmSelectItem_sendMessage() {
        // given
        let viewModel = self.makeViewModel(start: .someDay)
        
        // when
        viewModel.showPriorities()
        viewModel.selectPriority(ReadPriority.beforeDying.rawValue)
        viewModel.confirmSelect()
        
        // then
        XCTAssertEqual(self.didClose, true)
        XCTAssertEqual(self.didSelectedPriority, .beforeDying)
    }
    
    func testViewModel_whenNotChangedSelection_doNotSendMessage() {
        // given
        let viewModel = self.makeViewModel(start: .someDay)
        
        // when
        viewModel.showPriorities()
        viewModel.confirmSelect()
        
        // then
        XCTAssertEqual(self.didClose, true)
        XCTAssertEqual(self.didSelectedPriority, nil)
    }
}


// MARK: - EditReadPriorityViewModelTests_Change

class EditReadPriorityViewModelTests_change: EditReadPriorityViewModelTests, ReadPriorityUpdateListenable {
    
    var didSelectPriority: ReadPriority?
    var didUpdatedItem: ReadItem?
    
    override func tearDownWithError() throws {
        self.didSelectPriority = nil
        self.didUpdatedItem = nil
        try super.tearDownWithError()
    }
    
    private func dummyCollection(_ priority: ReadPriority? = nil) -> ReadCollection {
        return ReadCollection(name: "some")
            |> \.priority .~ priority
    }
    
    private func dummyLink(_ priority: ReadPriority? = nil) -> ReadLink {
        return ReadLink(link: "some")
            |> \.priority .~ priority
    }
    
    private func makeViewModel(item: ReadItem,
                               shouldFailUpdate: Bool = false) -> BaseEditReadPriorityViewModelImple {
        
        let scenario = StubReadItemUsecase.Scenario()
            |> \.updateLinkResult .~ (shouldFailUpdate ? .failure(ApplicationErrors.invalid) : .success(()))
            |> \.updateCollectionResult .~ (shouldFailUpdate ? .failure(ApplicationErrors.invalid) : .success(()))
        let stubUsecase = StubReadItemUsecase(scenario: scenario)
        
        return ReadPriorityChangeViewModelImple(item: item,
                                                updateUsecase: stubUsecase,
                                                router: self,
                                                listener: self)
    }
    
    func editReadPriority(didUpdate priority: ReadPriority, for item: ReadItem) {
        self.didSelectPriority = priority
        self.didUpdatedItem = item
    }
}


extension EditReadPriorityViewModelTests_change {
    
    // update -> did update + close
    func testViewModel_updatePriority() {
        // given
        let viewModel = self.makeViewModel(item: self.dummyCollection())
        
        // when
        viewModel.showPriorities()
        viewModel.selectPriority(ReadPriority.beforeDying.rawValue)
        viewModel.confirmSelect()
        
        // then
        XCTAssertEqual(self.didClose, true)
        XCTAssertEqual(self.didSelectPriority, .beforeDying)
        XCTAssertEqual(self.didUpdatedItem?.priority, .beforeDying)
    }
    
    // updating -> show processing
    func testViewModel_whenUpdatePriority_showProcessing() {
        // given
        let expect = expectation(description: "업데이트 중에는 진행상태 표시")
        expect.expectedFulfillmentCount = 3
        let viewModel = self.makeViewModel(item: self.dummyCollection())
        
        // when
        let isProcessings = self.waitElements(expect, for: viewModel.isProcessing) {
            viewModel.showPriorities()
            viewModel.selectPriority(ReadPriority.someDay.rawValue)
            viewModel.confirmSelect()
        }
        
        // then
        XCTAssertEqual(isProcessings, [false, true, false])
    }
    
    func testViewModel_updateCollectionItem() {
        // given
        let viewModel = self.makeViewModel(item: self.dummyCollection(.someDay))
        
        // when
        viewModel.showPriorities()
        viewModel.selectPriority(ReadPriority.beforeDying.rawValue)
        viewModel.confirmSelect()
        
        // then
        XCTAssert(self.didUpdatedItem is ReadCollection)
        XCTAssertEqual(self.didUpdatedItem?.priority, .beforeDying)
    }
    
    func testViewModel_updateLinkItem() {
        // given
        let viewModel = self.makeViewModel(item: self.dummyLink(.someDay))
        
        // when
        viewModel.showPriorities()
        viewModel.selectPriority(ReadPriority.beforeDying.rawValue)
        viewModel.confirmSelect()
        
        // then
        XCTAssert(self.didUpdatedItem is ReadLink)
        XCTAssertEqual(self.didUpdatedItem?.priority, .beforeDying)
    }
    
    // update fail
    func testViewModel_whenUpdateFail_alertError() {
        // given
        let viewModel = self.makeViewModel(item: self.dummyCollection(), shouldFailUpdate: true)
        
        // when
        viewModel.showPriorities()
        viewModel.selectPriority(ReadPriority.beforeDying.rawValue)
        viewModel.confirmSelect()
        
        // then
        XCTAssertEqual(self.didAlertPresented, true)
    }
    
    func testViewModel_whenSelectionNotChanged_justCloseScene() {
        // given
        let viewModel = self.makeViewModel(item: self.dummyLink(.someDay))
        
        // when
        viewModel.showPriorities()
        viewModel.selectPriority(ReadPriority.beforeDying.rawValue)
        viewModel.selectPriority(ReadPriority.someDay.rawValue)
        viewModel.confirmSelect()
        
        // then
        XCTAssertEqual(self.didClose, true)
        XCTAssertNil(self.didSelectPriority)
        XCTAssertNil(self.didUpdatedItem)
    }
}
