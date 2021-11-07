//
//  WaitMigrationViewModelTests.swift
//  MooyahoAppTests
//
//  Created by sudo.park on 2021/11/07.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit
import UsecaseDoubles

import MooyahoApp


class WaitMigrationViewModelTests: BaseTestCase, WaitObservableEvents, WaitMigrationRouting {
    
    var disposeBag: DisposeBag!
    var mockUsecase: MockUserDataMigrationUsecase!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.mockUsecase = nil
        self.didClose = nil
    }
    
    private func makeViewModel() -> WaitMigrationViewModel {
        
        self.mockUsecase = .init()
        return WaitMigrationViewModelImple(userID: "some", migrationUsecase: self.mockUsecase,
                                           router: self, listener: nil)
    }
    
    var didClose: (() -> Void)?
    func closeScene(animated: Bool, completed: (() -> Void)?) {
        self.didClose?()
        completed?()
    }
}


extension WaitMigrationViewModelTests {
    
    func testViewModel_updateMigrationStatus_byMigrating() {
        // given
        let expect = expectation(description: "마이그레이션 상태에 따라 상태 업데이트")
        expect.expectedFulfillmentCount = 2
        let viewModel = self.makeViewModel()
        
        // when
        let status = self.waitElements(expect, for: viewModel.migrationProcessAndResult) {
            viewModel.startMigration()
            self.mockUsecase.statusMocking.onNext(.finished)
        }
        
        // then
        XCTAssertEqual(status, [.migrating, .finished])
    }
    
    func testViewModel_updateStatus_whenMigrationFail() {
        // given
        let expect = expectation(description: "마이그레이션 실패시 따라 상태 업데이트")
        expect.expectedFulfillmentCount = 2
        let viewModel = self.makeViewModel()
        
        // when
        let status = self.waitElements(expect, for: viewModel.migrationProcessAndResult) {
            viewModel.startMigration()
            self.mockUsecase.statusMocking.onNext(.fail(ApplicationErrors.invalid))
        }
        
        // then
        XCTAssertEqual(status, [.migrating, .fail])
    }
    
    func testViewModel_whenMigrationEnd_updateMessage() {
        // given
        let expect = expectation(description: "마이그레이션 완료 이후에 메세지 업데이트")
        let viewModel = self.makeViewModel()
        
        // when
        let message = self.waitFirstElement(expect, for: viewModel.message) {
            viewModel.startMigration()
            self.mockUsecase.statusMocking.onNext(.finished)
        }
        
        // then
        XCTAssertEqual(message?.title, "Migration complete".localized)
        XCTAssertEqual(message?.description, "All data uploads are complete!".localized)
    }
    
    // migration fail -> update message
    func testViewModel_whenMigrationfail_updateMessage() {
        // given
        let expect = expectation(description: "마이그레이션 실패 이후에 메세지 업데이트")
        let viewModel = self.makeViewModel()
        
        // when
        let message = self.waitFirstElement(expect, for: viewModel.message) {
            viewModel.startMigration()
            self.mockUsecase.statusMocking.onNext(.fail(ApplicationErrors.invalid))
        }
        
        // then
        XCTAssertEqual(message?.title, "Migration failed".localized)
        XCTAssertEqual(message?.description, "Migration failed. Please try again after a while.\n(You can restart the operation from the settings screen.)".localized)
    }
}


extension WaitMigrationViewModelTests {
    
    // pause => cancel, close
    func testViewModel_whenDoMigrationLater_pauseAndClose() {
        // given
        let expect = expectation(description: "마이그레이션 동중 나중에하기 선택시 일시 중지하고 화면 닫음")
        let viewModel = self.makeViewModel()
        self.didClose = {
            expect.fulfill()
        }
        
        // when
        viewModel.startMigration()
        viewModel.doMigrationLater()
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(self.mockUsecase.didMigrationPaused, true)
    }
    
    func testViewModel_whenDoMigrationLaterAfterMigrationFail_justClose() {
        // given
        let expect = expectation(description: "마이그레이션 동중 나중에하기 선택시 화면 바로 닫음")
        let viewModel = self.makeViewModel()
        self.didClose = {
            expect.fulfill()
        }
        
        // when
        viewModel.startMigration()
        self.mockUsecase.statusMocking.onNext(.fail(ApplicationErrors.invalid))
        viewModel.doMigrationLater()
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(self.mockUsecase.didMigrationPaused, false)
    }
    
    // finish -> confirm -> close
    func testViewModel_whenMigrationFinishedd_confirmAndClose() {
        // given
        let expect = expectation(description: "마이그레이션 완료 이후에 화면닫기 확인")
        let viewModel = self.makeViewModel()
        
        self.didClose = {
            expect.fulfill()
        }
        
        // when
        viewModel.startMigration()
        self.mockUsecase.migratedItemMocking.onNext([ReadCollection.dummy(0)])
        self.mockUsecase.statusMocking.onNext(.finished)
        viewModel.confirmMigrationFinished()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    // finish -> nothing migrated -> auto close
    func testViewModel_whenMigrationFinishedAndNothingMigrated_autoClose() {
        // given
        let expect = expectation(description: "마이그레이션 완료했는데 실제 완료된거는 없다면 바로 닫기")
        let viewModel = self.makeViewModel()
        
        self.didClose = {
            expect.fulfill()
        }
        
        // when
        viewModel.startMigration()
        self.mockUsecase.migratedItemMocking.onNext([])
        self.mockUsecase.statusMocking.onNext(.finished)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}
