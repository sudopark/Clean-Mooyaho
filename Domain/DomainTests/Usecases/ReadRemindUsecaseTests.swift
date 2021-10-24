//
//  ReadRemindUsecaseTests.swift
//  DomainTests
//
//  Created by sudo.park on 2021/10/19.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift
import Prelude
import Optics

import UnitTestHelpKit

import Domain


class ReadRemindUsecaseTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var spyMessagingService: StubReminderMessagingService?
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.spyMessagingService = nil
    }
    
    private func makeUsecase(shouldFailSchedule: Bool = false,
                             shouldFailLoadPreview: Bool = false) -> ReadRemindUsecase {
        
        let store = SharedDataStoreServiceImple()
        
        let previewScenario = StubLinkPreviewRepository.Scenario()
            |> \.preview .~ (shouldFailLoadPreview ? .failure(ApplicationErrors.invalid) : .success(.dummy(0)))
        let previewRepo = StubLinkPreviewRepository(scenario: previewScenario)
        
        let repoScenario = StubReadItemRepository.Scenario()
            |> \.updateWithParamsResult .~ (shouldFailSchedule ? .failure(ApplicationErrors.invalid) : .success(()))
        let repository = StubReadItemRepository(scenario: repoScenario)
        
        let readItemUsecase = ReadItemUsecaseImple(itemsRespoitory: repository,
                                                   previewRepository: previewRepo,
                                                   optionsRespository: StubReadItemOptionsRepository(scenario: .init()),
                                                   authInfoProvider: store, sharedStoreService: store)
        
        let messageService = StubReminderMessagingService()
        self.spyMessagingService = messageService
        
        return ReadRemindUsecaseImple(authInfoProvider: store,
                                      sharedStore: store,
                                      readItemUsecase: readItemUsecase,
                                      messagingService: messageService)
    }
}


// MARK: - send collection remind message

extension ReadRemindUsecaseTests {
    
    func testUsecase_checkHasPermission() {
        // given
        let expect = expectation(description: "권한여부 조회")
        let usecase = self.makeUsecase()
        
        // when
        let chccking = usecase.preparePermission()
        let hasPermission = self.waitFirstElement(expect, for: chccking.asObservable())
        
        // then
        XCTAssertEqual(hasPermission, true)
    }
    
    func testUsecase_scheduleRemind_collectionItem() {
        // given
        let expect = expectation(description: "콜렉션 아이템 알림 예약")
        let usecase = self.makeUsecase(shouldFailSchedule: false)

        // when
        let scheduling = usecase.scheduleRemid(for: ReadCollection.dummy(0), futureTime: .now())
        let result: Void? = self.waitFirstElement(expect, for: scheduling.asObservable())

        // then
        XCTAssertNotNil(result)
    }
    
    func testUsecase_whenScheduleRemind_sendPendingMessage() {
        // given
        let expect = expectation(description: "알림 예약시에 지정된 시간으로 팬딩메세지 방출")
        let usecase = self.makeUsecase()
        
        // when
        let scheduling = usecase.scheduleRemid(for: ReadCollection.dummy(0), futureTime: .now())
        let _ : Void? = self.waitFirstElement(expect, for: scheduling.asObservable())
        
        // then
        XCTAssertNotNil(self.spyMessagingService?.didSentPendingMessage)
    }
    
    func testUsecase_scheduleRemind_fail() {
        // given
        let expect = expectation(description: "알림 예약 실패")
        let usecase = self.makeUsecase(shouldFailSchedule: true)

        // when
        let making = usecase.scheduleRemid(for: ReadCollection.dummy(0), futureTime: .now())
        let error: Error? = self.waitError(expect, for: making.asObservable())

        // then
        XCTAssertNotNil(error)
    }
}


// MARK: - send read link remind message

extension ReadRemindUsecaseTests {
    
    func testUsecase_scheduleReadLinkReminMessage() {
        // given
        let expect = expectation(description: "읽기 아이템 리마인드 메세지 전송")
        let usecase = self.makeUsecase()
        
        // when
        let scheduling = usecase.scheduleRemid(for: ReadLink.dummy(0), futureTime: .now())
        let result: Void? = self.waitFirstElement(expect, for: scheduling.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testUsecase_whenScheduleReadLinkRemind_sendPendingMessage() {
        // given
        let expect = expectation(description: "읽기 아이템 리마인드 등록시에 펜딩메세지 발송")
        let usecase = self.makeUsecase()
        
        // when
        let scheduling = usecase.scheduleRemid(for: ReadLink.dummy(0), futureTime: .now())
        let _ = self.waitFirstElement(expect, for: scheduling.asObservable())
        
        // then
        XCTAssertNotNil(self.spyMessagingService?.didSentPendingMessage)
    }
}


// MARK: - cancel remind

extension ReadRemindUsecaseTests {
    
    func testUsecase_cancelScheduleRemind() {
        // given
        let expect = expectation(description: "리마인드 취소")
        let usecase = self.makeUsecase()
        
        // when
        let canceling = usecase.cancelRemind(for: ReadLink.dummy(0))
        let result: Void? = self.waitFirstElement(expect, for: canceling.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testUsecase_whenCancelRemind_cancelPendingMessage() {
        // given
        let expect = expectation(description: "리마인드 취소시에 펜딩메세지도 취소")
        let usecase = self.makeUsecase()
        
        // when
        let canceling = usecase.cancelRemind(for: ReadLink.dummy(0))
        let _ : Void? = self.waitFirstElement(expect, for: canceling.asObservable())
        
        // then
        XCTAssertNotNil(self.spyMessagingService?.didCancelRemindID)
    }
}

// MARK: - handling readmind message

extension ReadRemindUsecaseTests {
    
    func testUsecase_whenHandlingReadRemindMessage_requestBroadcastToUsersOtherDevices() {
        // given
        let expect = expectation(description: "리마인드 메세지 수신시에 해당 메세지 다른 메세지로 전파")
        let usecase = self.makeUsecase()
        
        // when
        let handling = usecase.handleReminder(.dummy(0))
        let _ : Void? = self.waitFirstElement(expect, for: handling.asObservable())
        
        // then
        XCTAssertNotNil(self.spyMessagingService?.didBroadcastedMessage)
    }
}
