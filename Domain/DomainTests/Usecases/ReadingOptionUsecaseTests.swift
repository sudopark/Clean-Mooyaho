//
//  ReadingOptionUsecaseTests.swift
//  DomainTests
//
//  Created by sudo.park on 2022/05/28.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift
import Prelude
import Optics

import UnitTestHelpKit
import Domain


class ReadingOptionUsecaseTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var spyStore: SharedDataStoreServiceImple!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.spyStore = nil
    }
    
    private func makeUsecase(_ lastPosition: Double? = nil,
                             isLastReadPositionSaveOptionIsOn: Bool = true) -> ReadingOptionUsecase {
        
        let repository = StubRepository()
        repository.lastReadPosition = lastPosition.map { ReadPosition(itemID: "some", position: $0) }
        repository.isOptionOn = isLastReadPositionSaveOptionIsOn
        
        let store = SharedDataStoreServiceImple()
        self.spyStore = store
        return ReadingOptionUsecaseImple(readingOptionRepository: repository,
                                         sharedDataStore: store)
    }
}


extension ReadingOptionUsecaseTests {
    
    func testUsecase_saveLastReadPosition() {
        // given
        let expect = expectation(description: "마지막 읽음위치 저장")
        let usecase = self.makeUsecase()
        
        // when
        let updating = usecase.updateLastReadPositionIsPossible(for: "some", position: 13)
        let saved = self.waitFirstElement(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(saved)
    }
    
    func testUsecase_whenOptionIsOff_notUpdateLastReadPosition() {
        // given
        let expect = expectation(description: "옵션 꺼진 상태에서는 읽음위치 저장 안함")
        let usecase = self.makeUsecase(isLastReadPositionSaveOptionIsOn: false)
        
        // when
        let updating = usecase.updateLastReadPositionIsPossible(for: "some", position: 13)
        let error = self.waitError(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(error)
    }
    
    func testUsecase_loadLastReadPosition() {
        // given
        let expect = expectation(description: "마지막 읽음위치 로드")
        let usecase = self.makeUsecase(200)
        
        // when
        let loading = usecase.lastReadPosition(for: "some")
        let position = self.waitFirstElement(expect, for: loading.asObservable())
        
        // then
        XCTAssertEqual(position?.position, 200)
    }
    
    func testUsecase_whenOptionIsOff_snotLoadLastReadPosition() {
        // given
        let expect = expectation(description: "옵션 꺼진 상태에서는 마지막 읽음위치 로드 안함")
        let usecase = self.makeUsecase(200, isLastReadPositionSaveOptionIsOn: false)
        
        // when
        let loading = usecase.lastReadPosition(for: "some")
        let position = self.waitFirstElement(expect, for: loading.asObservable())
        
        // then
        XCTAssertNil(position)
    }
}


extension ReadingOptionUsecaseTests {
    
    func testUsecase_subscribeIsEnableLastReadPositionSaveOption_withLocalSavedValue() {
        // given
        let expect = expectation(description: "마지막 읽음위치 저장여부 변경 감지(초기값도 함께)")
        expect.expectedFulfillmentCount = 3
        let usecase = self.makeUsecase(isLastReadPositionSaveOptionIsOn: true)
        
        // when
        let isOns = self.waitElements(expect, for: usecase.isEnabledLastReadPositionSaveOption()) {
            usecase.updateEnableLastReadPositionSaveOption(false)
            usecase.updateEnableLastReadPositionSaveOption(true)
        }
        
        // then
        XCTAssertEqual(isOns, [true, false, true])
    }
}

extension ReadingOptionUsecaseTests {
    
    private class StubRepository: ReadingOptionRepository {
        
        var lastReadPosition: ReadPosition?
        func fetchLastReadPosition(for itemID: String) -> Maybe<ReadPosition?> {
            return .just(self.lastReadPosition)
        }
        
        func updateLastReadPosition(for itemID: String, _ position: Double) -> Maybe<ReadPosition> {
            return .just(.init(itemID: "some", position: 11))
        }
        
        var isOptionOn = true
        func updateEnableLastReadPositionSaveOption(_ isOn: Bool) {
            self.isOptionOn = isOn
        }
        
        func isEnabledLastReadPositionSaveOption() -> Bool {
            return self.isOptionOn
        }
    }
}
