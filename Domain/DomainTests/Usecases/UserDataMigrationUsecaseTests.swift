//
//  UserDataMigrationUsecaseTests.swift
//  DomainTests
//
//  Created by sudo.park on 2021/11/06.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Prelude
import Optics

import Domain
import UnitTestHelpKit


class UserDataMigrationUsecaseTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var stubRepository: StubUserDataMigrationRepository!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.stubRepository = nil
    }
    
    private var dummyItemCategorisChunk: [[ItemCategory]] {
        return (0..<201).makeDummyChunks(50) { ItemCategory.dummy($0) }
    }
    
    private var dummyReadItemChunk: [[ReadItem]] {
        return (0..<99).makeDummyChunks(50) { index -> ReadItem in
            return index % 10 == 0
                ? ReadCollection.dummy(index, parent: nil)
                : ReadLink.dummy(index, parent: nil)
        }
    }
    
    private var dummyReadLinkMemoChunk: [[ReadLinkMemo]] {
        return (0..<23).makeDummyChunks(50) { ReadLinkMemo.dummyID("\($0)") }
    }
    
    let mockItemUpdateSubject = PublishSubject<ReadItemUpdateEvent>()
    
    private func makeUsecase(isMigrationNeed: Bool = true,
                             isEmptyCategories: Bool = false,
                             isEmptyReadItem: Bool = false,
                             isEmptyMemo: Bool = false,
                             shouldFail: Bool = false) -> UserDataMigrationUsecase {
        
        let scenario = StubUserDataMigrationRepository.Scenario()
            |> \.isMigrationNeed .~ .success(isMigrationNeed)
            |> \.migrationNeedItemCategoryChunks .~ (isEmptyCategories ? [] : self.dummyItemCategorisChunk)
            |> \.migrationNeedReadItemChunks .~ (isEmptyReadItem ? [] : self.dummyReadItemChunk)
            |> \.migrationNeedReadLinkMemoChunks .~ (isEmptyMemo ? [] : self.dummyReadLinkMemoChunk)
            |> \.migrationError .~ (shouldFail ? ApplicationErrors.invalid as Error : nil)
        let repository = StubUserDataMigrationRepository(scenario: scenario)
        self.stubRepository = repository
        return UserDataMigrationUsecaseImple(migrationRepository: repository,
                                             readItemUpdateEventPublisher: self.mockItemUpdateSubject)
    }
}

extension UserDataMigrationUsecaseTests {
    
    // 마이그레이션 시작하고 시작으로 상태 변경
    func testUsecase_whenStartMigrate_updateStatusToMigrating() {
        // given
        let expect = expectation(description: "마이그레이션 진행하고 상태 진행중으로 변경하고 완료시 finish로")
        expect.expectedFulfillmentCount = 3
        let usecase = self.makeUsecase()
        
        // when
        let status = self.waitElements(expect, for: usecase.status) {
            usecase.startDataMigration(for: "some")
        }
        
        // then
        typealias Key = UserDataMigrationStatus
        XCTAssertEqual(status.map { $0.key } , [Key.idle, Key.migrating, Key.finished].map { $0.key })
    }
    
    // 카테고리 아이템 없으면 바로 다음단계로
    func testUsecase_whenItemCategoryIsEmpty_runMigrate() {
        // given
        let expect = expectation(description: "카테고리 없을때 마이그레이션 진행")
        expect.expectedFulfillmentCount = 3
        let usecase = self.makeUsecase(isEmptyCategories: true)
        
        // when
        let status = self.waitElements(expect, for: usecase.status) {
            usecase.startDataMigration(for: "some")
        }
        
        // then
        typealias Key = UserDataMigrationStatus
        XCTAssertEqual(status.map { $0.key } , [Key.idle, Key.migrating, Key.finished].map { $0.key })
    }
    
    // 리드아이템 없으면 바로 다음단계로
    func testUsecase_whenReadItemIsEmpty_runMigrate() {
        // given
        let expect = expectation(description: "아이템 없어도 마이그레이션 진행")
        expect.expectedFulfillmentCount = 3
        let usecase = self.makeUsecase(isEmptyReadItem: true)
        
        // when
        let status = self.waitElements(expect, for: usecase.status) {
            usecase.startDataMigration(for: "some")
        }
        
        // then
        typealias Key = UserDataMigrationStatus
        XCTAssertEqual(status.map { $0.key } , [Key.idle, Key.migrating, Key.finished].map { $0.key })
    }
    
    // 메모 없으면 바로 다음 단계
    func testUsecase_whenReadLinkMemoIsEmpty_runMigrate() {
        // given
        let expect = expectation(description: "메모 없어도 마이그레이션 진행")
        expect.expectedFulfillmentCount = 3
        let usecase = self.makeUsecase(isEmptyMemo: true)
        
        // when
        let status = self.waitElements(expect, for: usecase.status) {
            usecase.startDataMigration(for: "some")
        }
        
        // then
        typealias Key = UserDataMigrationStatus
        XCTAssertEqual(status.map { $0.key } , [Key.idle, Key.migrating, Key.finished].map { $0.key })
    }
    
    // 아이템 업데이트 될때마다 아이템 마이그레이션됨 이벤트 방출
    func testUsecase_whenMigrateReadItems_broadCaseItemsUpdated() {
        // given
        let expect = expectation(description: "아이템 마이그레이션 진행중에는 아이템 업데이트")
        expect.expectedFulfillmentCount = 2
        let usecase = self.makeUsecase()
        
        // when
        let itemChunks = self.waitElements(expect, for: usecase.migratedItems) {
            usecase.startDataMigration(for: "some")
        }
        
        // then
        XCTAssertEqual(itemChunks.flatMap { $0 }.count, 99)
    }
    
    func testUsecase_whenMigrationReadItems_publishItemUpdatedEvent() {
        // given
        let expect = expectation(description: "아이템 마이그레이션 진행중에는 아이템 업데이트 이벤트 방출")
        expect.assertForOverFulfill = false
        let usecase = self.makeUsecase()
        
        // when
        let event = self.waitFirstElement(expect, for: self.mockItemUpdateSubject, skip: 1) {
            usecase.startDataMigration(for: "some")
        }
        
        // then
        if case .updated = event {
            expect.fulfill()
        } else {
            XCTFail("기대하는 이벤트가 아님")
        }
    }
    
    func testUsecase_migrationFail() {
        // given
        let expect = expectation(description: "마이그레이션 실패")
        expect.expectedFulfillmentCount = 3
        let usecase = self.makeUsecase(shouldFail: true)
        
        // when
        let status = self.waitElements(expect, for: usecase.status) {
            usecase.startDataMigration(for: "some")
        }
        
        // then
        typealias Key = UserDataMigrationStatus
        XCTAssertEqual(status.map { $0.key },
                       [Key.idle, Key.migrating, Key.fail(ApplicationErrors.invalid)].map { $0.key })
    }
}

extension UserDataMigrationUsecaseTests {
    
    func testUsecase_resumeMigration() {
        // given
        let expect = expectation(description: "마이그레이션 재시작")
        expect.expectedFulfillmentCount = 3
        let usecase = self.makeUsecase()
        
        // when
        let status = self.waitElements(expect, for: usecase.status) {
            usecase.resumeMigrationIfNeed(for: "some")
        }
        
        // then
        typealias Key = UserDataMigrationStatus
        XCTAssertEqual(status.map { $0.key } , [Key.idle, Key.migrating, Key.finished].map { $0.key })
    }
    
    // 할필요 없으면 마이그레이션 진행 x
    func testUsecase_whenMigrationNotNeed_doNotRun() {
        // given
        let expect = expectation(description: "마이그레이션 진행할 필요없면 안함")
        let usecase = self.makeUsecase(isMigrationNeed: false)
        
        // when
        let status = self.waitElements(expect, for: usecase.status) {
            usecase.resumeMigrationIfNeed(for: "some")
        }
        
        // then
        typealias Key = UserDataMigrationStatus
        XCTAssertEqual(status.map { $0.key } , [Key.idle].map { $0.key })
    }
    
    // 마이그레이션 중지시 작업만 중지하고 상태 아이들로 변경
    func testUsecase_pauseMigration() {
        // given
        let expect = expectation(description: "마이그레이션 중지")
        expect.expectedFulfillmentCount = 3
        let usecase = self.makeUsecase()
        
        // when
        let status = self.waitElements(expect, for: usecase.status) {
            self.stubRepository.mockClearStorage = .init()
            usecase.resumeMigrationIfNeed(for: "some")
            usecase.pauseMigration()
        }
        
        // then
        typealias Key = UserDataMigrationStatus
        XCTAssertEqual(status.map { $0.key } , [Key.idle, Key.migrating, Key.idle].map { $0.key })
        XCTAssertEqual(self.stubRepository.didCleared, false)
    }
    
    // 마이그레이션 도중 캔슬시 아이들로 상태 변경 + 마이그레이션 대상 초기화
    func testUsecase_cancelMigration() {
        // given
        let expect = expectation(description: "마이그레이션 중지")
        expect.expectedFulfillmentCount = 3
        let usecase = self.makeUsecase()
        
        // when
        let status = self.waitElements(expect, for: usecase.status) {
            self.stubRepository.mockClearStorage = .init()
            usecase.resumeMigrationIfNeed(for: "some")
            usecase.cancelMigration()
        }
        
        // then
        typealias Key = UserDataMigrationStatus
        XCTAssertEqual(status.map { $0.key } , [Key.idle, Key.migrating, Key.idle].map { $0.key })
    }
}


private extension Range where Bound == Int {
    
    func makeDummyChunks<T>(_ pageSize: Int = 50, _ making: (Int) -> T) -> [[T]] {
        let sliceRanges = Array(self).slice(by: pageSize)
        
        let makeChunk: ([Int]) -> [T] = { subRange in
            return subRange.map(making)
        }
        return sliceRanges.map(makeChunk)
    }
}


private extension UserDataMigrationStatus {
    
    var key: String {
        switch self {
        case .idle: return "idle"
        case .migrating: return "migrating"
        case .finished: return "finished"
        case .fail: return "fail"
        }
    }
}
