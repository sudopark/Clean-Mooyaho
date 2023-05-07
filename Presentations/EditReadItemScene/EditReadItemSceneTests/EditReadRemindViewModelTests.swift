//
//  EditReadRemindViewModelTests.swift
//  EditReadItemSceneTests
//
//  Created by sudo.park on 2021/10/22.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import CommonPresenting
import Extensions

import UnitTestHelpKit
import UsecaseDoubles

import EditReadItemScene


class EditReadRemindViewModelTests: BaseTestCase, WaitObservableEvents, EditReadRemindRouting, EditReadRemindSceneListenable {
    
    var disposeBag: DisposeBag!
    var didSelectedTime: Date?
    var didClose: Bool?
    var didScheduled: TimeStamp?
    var didUpdatedItem: ReadItem?
    
    var didAlerted: Bool?
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.didSelectedTime = nil
        self.didClose = nil
        self.didScheduled = nil
        self.didUpdatedItem = nil
        self.didAlerted = nil
    }
    
    private func makeViewModel(editcase: EditRemindCase = .select(startWith: nil),
                               withoutPermission: Bool = false) -> EditReadRemindViewModel {
        
        let scenrio = StubReadRemindUsecase.Scenario()
            |> \.hasPermission .~ withoutPermission.invert()
        let usecaes = StubReadRemindUsecase(scenario: scenrio)
        
        return EditReadRemindViewModelImple(editcase,
                                            remindUsecase: usecaes,
                                            router: self, listener: self)
    }
    
    func editReadRemind(didSelect time: Date?) {
        self.didSelectedTime = time
    }
    
    func editReadRemind(didUpdate item: ReadItem) {
        self.didUpdatedItem = item
    }
    
    func closeScene(animated: Bool, completed: (() -> Void)?) {
        self.didClose = true
        completed?()
    }
    
    func openAlertSetting() { }
    
    func alertForConfirm(_ form: AlertForm) {
        self.didAlerted = true
    }
}


extension EditReadRemindViewModelTests {
    
    func testViewModel_whenAfterEnterScene_ifAlertPermissionDisabled_askPermission() {
        // given
        let viewModel = self.makeViewModel(withoutPermission: true)
        
        // when
        viewModel.checkPermission()
        
        // then
        XCTAssertEqual(self.didAlerted, true)
    }
    
    func testViewModel_whenSelectCaseAndReEnterSelectRemindScene_startWithPreviousSelectedvalue() {
        // given
        let expect = expectation(description: "선택케이스에서 다시 진입시에 이전값 최초 노출")
        let previousTime = TimeStamp.now() + 100
        let viewModel = self.makeViewModel(editcase: .select(startWith: previousTime))
        
        // when
        let initial = self.waitFirstElement(expect, for: viewModel.initialDate)
        
        // then
        XCTAssertEqual(initial?.timeIntervalSince1970, previousTime)
    }
    
    func testViewModel_whenEditCase_initialDateRemindTime() {
        // given
        let expect = expectation(description: "수정케이스에서 초기시간은 수정하는 리마인드의 예정 시간")
        let item = ReadLink.dummy(0) |> \.remindTime .~ (.now() + 1000)
        let viewModel = self.makeViewModel(editcase: .edit(item))
        
        // when
        let initial = self.waitFirstElement(expect, for: viewModel.initialDate)
        
        // then
        XCTAssertEqual(initial, item.remindTime.map { Date(timeIntervalSince1970: $0) })
    }
    
    func testViewModel_whenSelectCase_updateConfirmWithSelectedtime() {
        // given
        let expct = expectation(description: "선택된 날짜에 따라(미래의 경우에만) 확인버튼 활성화")
        expct.expectedFulfillmentCount = 3
        let viewModel = self.makeViewModel(editcase: .select(startWith: nil))
        
        // when
        let isConfirmables = self.waitElements(expct, for: viewModel.isConfirmable) {
            let futureDate = Date().addingTimeInterval(100)
            viewModel.selectDate(futureDate)
            
            let pastDate = Date()
            viewModel.selectDate(pastDate)
        }
        
        // then
        XCTAssertEqual(isConfirmables, [false, true, false])
    }
    
    func testViewModel_updateButtonTitle_bySelectedTime() {
        // given
        let expect = expectation(description: "선택한 날짜에따라 선택버튼 타이틀 업데이트")
        expect.expectedFulfillmentCount = 3
        let newTime = TimeStamp.now() + 200
        let pastTime = TimeStamp.now() - 100
        let viewModel = self.makeViewModel(editcase: .select(startWith: nil))
        
        // when
        let titles = self.waitElements(expect, for: viewModel.confirmButtonTitle) {
            viewModel.selectDate(Date(timeIntervalSince1970: newTime))
            viewModel.selectDate(Date(timeIntervalSince1970: pastTime))
        }
        
        // then
        XCTAssertEqual(titles, [
            "Select a future time".localized,
            newTime.remindTimeText(),
            "Select a future time".localized
        ])
    }
    
    func testViewModel_selectTime() {
        // given
        let viewModel = self.makeViewModel(editcase: .select(startWith: nil))
        
        // when
        viewModel.selectDate(Date().addingTimeInterval(100))
        viewModel.confirmSelectRemindTime()
        
        // then
        XCTAssertEqual(self.didClose, true)
        XCTAssertNotNil(self.didSelectedTime)
    }
    
    func testViewModel_editRemindForItem() {
        // given
        let item = ReadLink.dummy(0) |> \.remindTime .~ (.now() + 1000)
        let viewModel = self.makeViewModel(editcase: .edit(item))
        
        // when
        viewModel.selectDate(Date().addingTimeInterval(100))
        viewModel.confirmSelectRemindTime()
        
        // then
        XCTAssertEqual(self.didClose, true)
        XCTAssertNotNil(self.didUpdatedItem)
    }
    
    func testViewModel_showClearButtonWhenSelectMode() {
        // given
        let viewModel = self.makeViewModel(editcase: .select(startWith: nil))
        
        // when
        let show = viewModel.showClearButton
        
        // then
        XCTAssertEqual(show, true)
    }
    
    func testViewmodel_whenSelectCase_clearSelection() {
        // given
        let viewModel = self.makeViewModel(editcase: .select(startWith: nil))
        
        // when
        viewModel.selectDate(.init().addingTimeInterval(100))
        viewModel.clearSelect()
        
        // then
        XCTAssertEqual(self.didClose, true)
        XCTAssertEqual(self.didSelectedTime, nil)
    }
}
