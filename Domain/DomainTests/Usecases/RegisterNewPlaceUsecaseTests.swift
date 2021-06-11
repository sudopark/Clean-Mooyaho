//
//  RegisterNewPlaceUsecaseTests.swift
//  DomainTests
//
//  Created by sudo.park on 2021/05/10.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import UnitTestHelpKit

@testable import Domain


class RegisterNewPlaceUsecaseTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var stubPlaceRepository: StubPlaceRepository!
    var usecase: RegisterNewPlaceUsecaseImple!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = .init()
        self.stubPlaceRepository = .init()
        self.usecase = .init(placeRepository: self.stubPlaceRepository)
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.stubPlaceRepository = nil
        self.usecase = nil
        super.tearDown()
    }
    
    private func dummyPosition() -> Coordinate {
        return Coordinate(latt: 0, long: 0)
    }
    
    private func outOfRangePosition() -> Coordinate {
        return Coordinate(latt: 36, long: 127)
    }
    
    private func dummyPendingForm() -> NewPlaceForm {
        let builder = NewPlaceFormBuilder(base: .init(reporterID: "some", infoProvider: .userDefine))
            .title("title")
            .coordinate(self.dummyPosition())
            .address("address")
            .categoryTags([PlaceCategoryTag(placeCat: "dummy", emoji: "☠️")])
        return builder.build()!
    }
}


extension RegisterNewPlaceUsecaseTests {
    
    func testUsecase_whenPendingRegisterNewPlaceFormWithInDistanceNotExist_resultIsNil() {
        // given
        let expect = expectation(description: "최근에 입력중이던 form이 없으면 결과는 nil")
        
        self.stubPlaceRepository.register(key: "fetchRegisterPendingNewPlaceForm") {
            return Maybe<PendingRegisterNewPlaceForm?>.just(nil)
        }
        
        // when
        let currentUserLocation = self.dummyPosition()
        let loading = self.usecase.loadRegisterPendingNewPlaceForm(withIn: currentUserLocation)
        let pendingForm = self.waitFirstElement(expect, for: loading.asObservable()) {}
        
        // then
        XCTAssertNil(pendingForm)
    }
    
    func testUsecase_whenLoadPendingRegisterNewPlaceFormWithDistance_returnPendingForm() {
        // give
        let expect = expectation(description: "유효범위내에 입력중이던 플레이스 정보가 존재하면 폼 리턴")
        self.stubPlaceRepository.register(type: Maybe<PendingRegisterNewPlaceForm?>.self, key: "fetchRegisterPendingNewPlaceForm") {
            let pendingForm = PendingRegisterNewPlaceForm(self.dummyPendingForm(), Date())
            return .just(pendingForm)
        }
        
        // when
        let currentUserLocation = self.dummyPosition()
        let loading = self.usecase.loadRegisterPendingNewPlaceForm(withIn: currentUserLocation)
        let pendingForm = self.waitFirstElement(expect, for: loading.asObservable()) {}
        
        // then
        XCTAssertNotNil(pendingForm)
    }
    
    func testUsecase_whenPendingRegisterNewPlaceFormExistsButOutofDistance_returnFormIfNotTooOld() {
        // given
        let expect = expectation(description: "폼이 존재하는데 현재위치랑 너무 멀더라도 너무 오래되지 않았다면 리턴")
        self.stubPlaceRepository.register(type: Maybe<PendingRegisterNewPlaceForm?>.self, key: "fetchRegisterPendingNewPlaceForm") {
            let pendingForm = PendingRegisterNewPlaceForm(self.dummyPendingForm(), Date())
            return .just(pendingForm)
        }
        
        // when
        let currentUserLocation = self.outOfRangePosition()
        let loading = self.usecase.loadRegisterPendingNewPlaceForm(withIn: currentUserLocation)
        let pendingForm = self.waitFirstElement(expect, for: loading.asObservable()) {}
        
        // then
        XCTAssertNotNil(pendingForm)
    }
    
    func testUsecase_whenPendingRegisterNewPlaceFormExistsAndOutOfDistanceAndTooOld_resultIsNil() {
        // given
        let expect = expectation(description: "폼이 존재하는데 현재위치랑 너무 멀고 너무 오래되었다면 nil 리턴")
        self.stubPlaceRepository.register(type: Maybe<PendingRegisterNewPlaceForm?>.self, key: "fetchRegisterPendingNewPlaceForm") {
            let oldDate = Date().addingTimeInterval(-60*24)
            let pendingForm = PendingRegisterNewPlaceForm(self.dummyPendingForm(), oldDate)
            return .just(pendingForm)
        }
        
        // when
        let currentUserLocation = self.outOfRangePosition()
        let loading = self.usecase.loadRegisterPendingNewPlaceForm(withIn: currentUserLocation)
        let pendingForm = self.waitFirstElement(expect, for: loading.asObservable()) {}
        
        // then
        XCTAssertNotNil(pendingForm)
    }
}

extension RegisterNewPlaceUsecaseTests {
    
    func testUsecase_whenFinishInputPlaceInfo_saveNewPlaceForm() {
        // given
        let expect = expectation(description: "place 정보 입력 완료시에 캐시에 저장")
        
        self.stubPlaceRepository.called(key: "savePendingRegister") { _ in
            expect.fulfill()
        }
        
        // when
        self.usecase.finishInputPlaceInfo(self.dummyPendingForm())
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}

extension RegisterNewPlaceUsecaseTests {
    
    func testUsecase_uploadNewPlace() {
        // given
        let expect = expectation(description: "신규장소 업로드")
        
        self.stubPlaceRepository.register(key: "requestUpload") {
            return Maybe<Place>.just(Place.dummy(0))
        }
        
        // when
        let uploading = self.usecase.uploadNewPlace(self.dummyPendingForm())
        let newPlace = self.waitFirstElement(expect, for: uploading.asObservable()) {}
        
        // then
        XCTAssertNotNil(newPlace)
    }
}
