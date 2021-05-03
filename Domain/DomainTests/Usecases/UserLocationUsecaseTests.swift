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
    var stubLocationMonitoringService: StubLocationMonitoringService!
    var stubPlaceRepository: StubPlaceRepository!
    var usecase: UserLocationUsecaseImple!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = DisposeBag()
        self.stubLocationMonitoringService = .init()
        self.stubPlaceRepository = .init()
        self.usecase = .init(locationMonitoringService: self.stubLocationMonitoringService,
                             placeRepository: self.stubPlaceRepository)
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.stubLocationMonitoringService = nil
        self.stubPlaceRepository = nil
        self.usecase = nil
        super.tearDown()
    }
}


extension UserLocationUsecaseTests {
    
    func testUsecase_checkHasPermission() {
        // given
        let expect = expectation(description: "위치 서비스 권한 조사")
        self.stubLocationMonitoringService.register(key: "checkHasPermission") {
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
        self.stubLocationMonitoringService.register(key: "requestPermission") {
            return Maybe<Bool>.just(true)
        }
        
        // when
        let granted = self.waitFirstElement(expect, for: self.usecase.requestPermission().asObservable()) { }
        
        // then
        XCTAssertNotNil(granted)
    }
}


extension UserLocationUsecaseTests {
    
    func testUsecase_startUploadUserLocation_withThrottling() {
        // given
        let expect = expectation(description: "유저 위치정보 업로드 시작")
        expect.expectedFulfillmentCount = 2
        var locations: [UserLocation] = []
        
        self.stubPlaceRepository.called(key: "uploadLocation") { args in
            guard let location = args as? UserLocation else { return }
            locations.append(location)
            expect.fulfill()
        }
        
        // when
        let throttleInterval = Int(self.timeout * 1000) - 1
        let option = LocationMonitoringOption(throttling: throttleInterval, accuracy: .tenMeters, distanceFilter: 10)
        self.usecase.startUploadUserLocation(with: option, for: Member(uid: "dummy"))
        
        (0..<10).forEach { index in
            let lastLocation = LastLocation(lattitude: Double(index), longitude: Double(index), timeStamp: Date().timeIntervalSince1970)
            self.stubLocationMonitoringService.stubLocationSubject.onNext(lastLocation)
        }
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(locations.count, 2)
        XCTAssertEqual(locations.first?.lastLocation.lattitude, 0.0)
        XCTAssertEqual(locations.last?.lastLocation.lattitude, 9.0)
    }
    
    func testUsecase_whenStopUploadUserLocation_notUploadLocations() {
        // given
        let expect = expectation(description: "유저 위치정보 업로드 시작")
        expect.isInverted = true
        self.stubPlaceRepository.called(key: "uploadLocation") { args in
            expect.fulfill()
        }
        
        // when
        let throttleInterval = Int(self.timeout * 1000) - 1
        let option = LocationMonitoringOption(throttling: throttleInterval, accuracy: .tenMeters, distanceFilter: 10)
        self.usecase.startUploadUserLocation(with: option, for: Member(uid: "dummy"))
        self.usecase.stopUplocationUserLocation()
        
        self.stubLocationMonitoringService.stubLocationSubject.onNext(.init(lattitude: 0, longitude: 0, timeStamp: 0))
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}
