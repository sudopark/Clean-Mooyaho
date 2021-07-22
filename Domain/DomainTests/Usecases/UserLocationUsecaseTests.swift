//
//  UserLocationUsecaseTests.swift
//  DomainTests
//
//  Created by ParkHyunsoo on 2021/05/03.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import UnitTestHelpKit

@testable import Domain


class UserLocationUsecaseTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var mockLocationMonitoringService: MockLocationMonitoringService!
    var mockPlaceRepository: MockPlaceRepository!
    var usecase: UserLocationUsecaseImple!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = DisposeBag()
        self.mockLocationMonitoringService = .init()
        self.mockPlaceRepository = .init()
        self.usecase = .init(locationMonitoringService: self.mockLocationMonitoringService,
                             placeRepository: self.mockPlaceRepository)
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.mockLocationMonitoringService = nil
        self.mockPlaceRepository = nil
        self.usecase = nil
        super.tearDown()
    }
}


extension UserLocationUsecaseTests {
    
    func testUsecase_checkHasPermission() {
        // given
        let expect = expectation(description: "위치 서비스 권한 조사")
        self.mockLocationMonitoringService.register(key: "checkHasPermission") {
            return Maybe<LocationServiceAccessPermission>.just(.granted)
        }
        
        // when
        let permission = self.waitFirstElement(expect, for: self.usecase.checkHasPermission().asObservable()) { }
        
        // then
        XCTAssertEqual(permission, .granted)
    }
    
    func testUsecase_requestLocationServicePermission() {
        // given
        let expect = expectation(description: "위치서비스 어세스 요청")
        self.mockLocationMonitoringService.register(key: "requestPermission") {
            return Maybe<Bool>.just(true)
        }
        
        // when
        let granted = self.waitFirstElement(expect, for: self.usecase.requestPermission().asObservable()) { }
        
        // then
        XCTAssertNotNil(granted)
    }
    
    func testUsecase_autorizedStatusChange() {
        // given
        let expect = expectation(description: "권한여부 업데이트 전파")
        expect.expectedFulfillmentCount = 2
        
        // when
        let isAuthorizeds = self.waitElements(expect, for: self.usecase.isAuthorized) {
            self.mockLocationMonitoringService.autorized.onNext(false)
            self.mockLocationMonitoringService.autorized.onNext(true)
        }
        
        // then
        XCTAssertEqual(isAuthorizeds, [false, true])
    }
}


extension UserLocationUsecaseTests {
    
    func testUsecase_fetchUserLocation() {
        // given
        let expect = expectation(description: "유저 위치 로드")
        
        self.mockLocationMonitoringService.register(key: "fetchLastLocation") {
            return Maybe<LastLocation>.just(.init(lattitude: 0, longitude: 0, timeStamp: 0))
        }
        
        // when
        let fetch = self.usecase.fetchUserLocation()
        let location = self.waitFirstElement(expect, for: fetch.asObservable()) { }
        
        // then
        XCTAssertNotNil(location)
    }
    
    func testUsecase_startUploadUserLocation_withThrottling() {
        // given
        let expect = expectation(description: "유저 위치정보 업로드 시작")
        var locations: [UserLocation] = []
        
        self.mockPlaceRepository.called(key: "uploadLocation") { args in
            guard let location = args as? UserLocation else { return }
            locations.append(location)
            expect.fulfill()
        }
        
        // when
        self.usecase.startUploadUserLocation(for: "dummy")
        
        (0..<10).forEach { index in
            let lastLocation = LastLocation(lattitude: Double(index), longitude: Double(index), timeStamp: Date().timeIntervalSince1970)
            self.mockLocationMonitoringService.locationSubject.onNext(lastLocation)
        }
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(locations.count, 1)
    }
    
    func testUsecase_whenStopUploadUserLocation_notUploadLocations() {
        // given
        let expect = expectation(description: "유저 위치정보 업로드 중지")
        expect.isInverted = true
        self.mockPlaceRepository.called(key: "uploadLocation") { args in
            expect.fulfill()
        }
        
        // when
        self.usecase.startUploadUserLocation(for: "dummy")
        self.usecase.stopUplocationUserLocation()
        
        self.mockLocationMonitoringService.locationSubject.onNext(.init(lattitude: 0, longitude: 0, timeStamp: 0))
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}
