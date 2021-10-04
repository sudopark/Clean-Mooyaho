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

import EditReadItemScene


class EditReadPriorityViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var didClose: Bool?
    var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.didClose = nil
    }
    
    func makeViewModel(editCase: EditPriorityCase) -> BaseEditReadPriorityViewModelImple {
        
        return BaseEditReadPriorityViewModelImple(editCase: editCase, router: self, listener: nil)
    }
}


extension EditReadPriorityViewModelTests {
    
    func testViewModel_showPriorities_withOrder() {
        // given
        let expect = expectation(description: "우선순위 목록 노출시에 높은것부터 노출")
        let viewModel = self.makeViewModel(editCase: .makeNew())
        
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
        let viewModel = self.makeViewModel(editCase: .makeNew(startWithSelect: .someDay))
        
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
        let viewModel = self.makeViewModel(editCase: .makeNew(startWithSelect: .someDay))
        
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
}



// MARK: - EditReadPriorityViewModelTests_select

class EditReadPriorityViewModelTests_select: EditReadPriorityViewModelTests, ReadPrioritySelectListenable {
    
    var didSelectedPriority: ReadPriority?
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        self.didSelectedPriority = nil
    }
    
    override func makeViewModel(editCase: EditPriorityCase) -> BaseEditReadPriorityViewModelImple {
        return ReadPrioritySelectViewModelImple(editCase: editCase, router: self, listener: self)
    }
    
    func editReadPriority(didSelect priority: ReadPriority) {
        self.didSelectedPriority = priority
    }
}


extension EditReadPriorityViewModelTests_select {
    
    func testViewModel_whenConfirmSelectItem_sendMessage() {
        // given
        let viewModel = self.makeViewModel(editCase: .makeNew(startWithSelect: .someDay))
        
        // when
        viewModel.showPriorities()
        viewModel.selectPriority(ReadPriority.beforeDying.rawValue)
        viewModel.confirmSelect()
        
        // then
        XCTAssertEqual(self.didClose, true)
        XCTAssertEqual(self.didSelectedPriority, .beforeDying)
    }
}
