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
import UnitTestHelpKit
import UsecaseDoubles

import EditReadItemScene


class EditReadRemindViewModelTests: BaseTestCase, WaitObservableEvents, EditReadRemindRouting, EditReadRemindSceneListenable {
    
    var disposeBag: DisposeBag!
    var didSelectedTime: Date?
    var didClose: Bool?
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.didSelectedTime = nil
        self.didClose = nil
    }
    
    private func makeViewModel(editcase: EditRemindCase = .makeNew) -> EditReadRemindViewModel {
        
        let scenrio = StubReadRemindUsecase.Scenario()
        let usecaes = StubReadRemindUsecase(scenario: scenrio)
        
        return EditReadRemindViewModelImple(editcase,
                                            remindUsecase: usecaes,
                                            router: self, listener: self)
    }
    
    func editreadReadRemind(didSelect time: Date) {
        self.didSelectedTime = time
    }
    
    func closeScene(animated: Bool, completed: (() -> Void)?) {
        self.didClose = true
        completed?()
    }
}


// MARK: - test make case

extension EditReadRemindViewModelTests {
    
    func testViewModel_makeNewCase_initialDateIsNowWithoutTime() {
        // given
        let expect = expectation(description: "생성케이스 에서는 초기 날짜값이 시간 없이 현재날짜")
        let viewModel = self.makeViewModel(editcase: .makeNew)
        
        // when
        let initial = self.waitFirstElement(expect, for: viewModel.initialDate)
        
        // then
        let interval = initial.map { Date().timeIntervalSince($0) }
        XCTAssert(interval ?? 0 > 0)
        XCTAssert(interval ?? 0 < 1)
    }
    
    func testViewModel_whenMakecase_updateConfirmWithSelectedtime() {
        // given
        let expct = expectation(description: "선택된 날짜에 따라(미래의 경우에만) 확인버튼 활성화")
        expct.expectedFulfillmentCount = 3
        let viewModel = self.makeViewModel(editcase: .makeNew)
        
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
    
    func testViewModel_selectTime() {
        // given
        let viewModel = self.makeViewModel(editcase: .makeNew)
        
        // when
        viewModel.selectDate(Date().addingTimeInterval(100))
        viewModel.confirmSelectRemindTime()
        
        // then
        XCTAssertEqual(self.didClose, true)
        XCTAssertNotNil(self.didSelectedTime)
    }
}
