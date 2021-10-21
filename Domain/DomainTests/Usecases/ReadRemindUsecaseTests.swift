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
import UsecaseDoubles

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
                             shouldFailLoadPreview: Bool = false,
                             prepareRemind: ReadRemind? = nil) -> ReadRemindUsecase {
        
        let store = SharedDataStoreServiceImple()
        prepareRemind.whenExists {
            store.save([String: ReadRemind].self, key: .readMindersMap, [$0.itemID: $0])
        }
        
        let previewScenario = StubLinkPreviewRepository.Scenario()
            |> \.preview .~ (shouldFailLoadPreview ? .failure(ApplicationErrors.invalid) : .success(.dummy(0)))
        let previewRepo = StubLinkPreviewRepository(scenario: previewScenario)
        let readItemUsecase = ReadItemUsecaseImple(itemsRespoitory: StubReadItemRepository(),
                                                   previewRepository: previewRepo,
                                                   optionsRespository: StubReadItemOptionsRepository(scenario: .init()),
                                                   authInfoProvider: store, sharedStoreService: store)
        
        let repoScenario = StubReadRemiderReposiotry.Scenario()
            |> \.makeReminderResult .~ (shouldFailSchedule ? .failure(ApplicationErrors.invalid) : .success(()))
        let repository = StubReadRemiderReposiotry(scenario: repoScenario)
        
        let messageService = StubReminderMessagingService()
        self.spyMessagingService = messageService
        
        return ReadRemindUsecaseImple(authInfoProvider: store,
                                      sharedStore: store,
                                      readItemUsecase: readItemUsecase,
                                      reminderRepository: repository,
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
        let scheduling = usecase.scheduleRemind(for: ReadCollection.dummy(0), at: .now())
        let remind: ReadRemind? = self.waitFirstElement(expect, for: scheduling.asObservable())

        // then
        XCTAssertNotNil(remind)
    }
    
    func testUsecase_whenScheduleRemind_sendPendingMessage() {
        // given
        let expect = expectation(description: "알림 예약시에 지정된 시간으로 팬딩메세지 방출")
        let usecase = self.makeUsecase()
        
        // when
        let scheduling = usecase.scheduleRemind(for: ReadCollection.dummy(0), at: .now())
        let _ : ReadRemind? = self.waitFirstElement(expect, for: scheduling.asObservable())
        
        // then
        XCTAssertNotNil(self.spyMessagingService?.didSentPendingMessage)
    }
    
    func testUsecase_scheduleRemind_fail() {
        // given
        let expect = expectation(description: "알림 예약 실패")
        let usecase = self.makeUsecase(shouldFailSchedule: true)

        // when
        let making = usecase.scheduleRemind(for: ReadCollection.dummy(0), at: .now())
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
        let scheduling = usecase.scheduleRemind(for: ReadLink.dummy(0), at: .now())
        let remind = self.waitFirstElement(expect, for: scheduling.asObservable())
        
        // then
        XCTAssertNotNil(remind)
    }
    
    func testUsecase_whenScheduleReadLinkRemind_sendPendingMessage() {
        // given
        let expect = expectation(description: "읽기 아이템 리마인드 등록시에 펜딩메세지 발송")
        let usecase = self.makeUsecase()
        
        // when
        let scheduling = usecase.scheduleRemind(for: ReadLink.dummy(0), at: .now())
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
        let canceling = usecase.cancelRemind(.dummy(0))
        let result: Void? = self.waitFirstElement(expect, for: canceling.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testUsecase_whenCancelRemind_cancelPendingMessage() {
        // given
        let expect = expectation(description: "리마인드 취소시에 펜딩메세지도 취소")
        let usecase = self.makeUsecase()
        
        // when
        let canceling = usecase.cancelRemind(.dummy(0))
        let _ : Void? = self.waitFirstElement(expect, for: canceling.asObservable())
        
        // then
        XCTAssertNotNil(self.spyMessagingService?.didCancelRemindID)
    }
    
    func testUSecase_whenAfterCancelRemind_updateSharedStore() {
        // given
        let expect = expectation(description: "에정된 알림 취소 이후에 공유 데이터 업데이트")
        expect.expectedFulfillmentCount = 2
        let usecase = self.makeUsecase()
        
        // when
        let reminds = self.waitElements(expect, for: usecase.readReminds(for: ["c:0"])) {
            usecase.cancelRemind(.dummy(0))
                .subscribe().disposed(by: self.disposeBag)
        }
        
        // then
        XCTAssertEqual(reminds.map { $0.count }, [1, 0])
    }
}


extension ReadRemindUsecaseTests {
    
    
    func testUsecase_loadRemind_withoutShared() {
        // given
        let expect = expectation(description: "미리 로드된 리마인드 없이 리마인드 아이템 로드")
        let usecase = self.makeUsecase()
        
        // when
        let loadnig = usecase.readReminds(for: ["c:0"])
        let reminds = self.waitElements(expect, for: loadnig)
        
        // then
        XCTAssertEqual(reminds.map { $0.count }, [1])
    }
    
    func testUsecase_whenRemindExistOnSharedStore_startWuthIt() {
        // given
        let expect = expectation(description: "미리 로드된 리마인드 존재시에 해당값 먼저 방출")
        expect.expectedFulfillmentCount = 2
        let usecase = self.makeUsecase(prepareRemind: ReadRemind.dummy(0))
        
        // when
        let loadnig = usecase.readReminds(for: ["c:0"])
        let reminds = self.waitElements(expect, for: loadnig)
        
        // then
        XCTAssertEqual(reminds.map { $0.count }, [1, 1])
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
