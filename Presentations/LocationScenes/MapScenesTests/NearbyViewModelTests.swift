//
//  NearbyViewModelTests.swift
//  LocationScenesTests
//
//  Created by sudo.park on 2021/05/23.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit
import StubUsecases

@testable import MapScenes


class NearbyViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var mockLocationUsecase: MockUserLocationUsecase!
    var spyRouter: SpyRouter!
    var viewModel: NearbyViewModelImple!
    
    override func setUpWithError() throws {
        self.disposeBag = DisposeBag()
        self.mockLocationUsecase = .init()
        self.spyRouter = .init()
        self.viewModel = NearbyViewModelImple(locationUsecase: self.mockLocationUsecase,
                                              router: self.spyRouter)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.mockLocationUsecase = nil
        self.spyRouter = nil
        self.viewModel = nil
    }
}


extension NearbyViewModelTests {
    
    func testViewModel_whenHasNoAuthorixed_moveCameraToDefaultLocation() {
        // given
        let expect = expectation(description: "최초에 권한여부 조회해서 승인받지 않은 상태라면 디폴트위치로 카메라 이동")
        
        self.mockLocationUsecase.register(key: "checkHasPermission") {
            return Maybe<LocationServiceAccessPermission>.just(.rejected)
        }
        
        // when
        let moving = self.waitFirstElement(expect, for: self.viewModel.cameraPosition) {
            self.viewModel.preparePermission()
        }
        
        // then
        if case .default = moving {
            XCTAssert(true)
        } else {
            XCTFail("기대하는 카메라 위치가 아님")
        }
    }
    
    func testViewModel_whenAuthorizeStatusNotDetermied_requestAndGranted_moveCameraToCurrentPosition() {
        // given
        let expect = expectation(description: "권한 아직 판단 안되었으면 요청하고 승인 -> 현재 위치로 카메라 이동")
        
        self.mockLocationUsecase.register(key: "checkHasPermission") {
            return Maybe<LocationServiceAccessPermission>.just(.notDetermined)
        }
        self.mockLocationUsecase.register(key: "requestPermission") {
            return Maybe<Bool>.just(true)
        }
        self.mockLocationUsecase.register(key: "fetchUserLocation") {
            return Maybe<LastLocation>.just(.init(lattitude: 0, longitude: 0, timeStamp: 0))
        }
        
        // when
        let moving = self.waitFirstElement(expect, for: self.viewModel.cameraPosition) {
            self.viewModel.preparePermission()
        }
        
        // then
        if case .userLocation = moving {
            XCTAssert(true)
        } else {
            XCTFail("기대하는 카메라 위치가 아님")
        }
    }
    
    // 요청 완료 이후에 거절시 에러
    func testViewModel_whenAuthorizeStatusNotDetermied_requestAndRejected_moveCameraToDefaultPosition() {
        // given
        let expect = expectation(description: "권한 아직 판단 안되었으면 요청하고 거절 -> 디폴트 위치로 카메라 이동")
        
        self.mockLocationUsecase.register(key: "checkHasPermission") {
            return Maybe<LocationServiceAccessPermission>.just(.notDetermined)
        }
        self.mockLocationUsecase.register(key: "requestPermission") {
            return Maybe<Bool>.just(false)
        }
        
        // when
        let moving = self.waitFirstElement(expect, for: self.viewModel.cameraPosition) {
            self.viewModel.preparePermission()
        }
        
        // then
        if case .default = moving {
            XCTAssert(true)
        } else {
            XCTFail("기대하는 카메라 위치가 아님")
        }
    }
    
    func testViewModel_whenAuthorizeStatusNotDetermied_requestAndRejected_alertUnavailToUseService() {
        // given
        let expect = expectation(description: "권한 아직 판단 안되었으면 요청하고 거절 -> 서비스 사용 불가 알림")
        
        self.mockLocationUsecase.register(key: "checkHasPermission") {
            return Maybe<LocationServiceAccessPermission>.just(.notDetermined)
        }
        self.mockLocationUsecase.register(key: "requestPermission") {
            return Maybe<Bool>.just(false)
        }
        
        // when
        let void: Void? = self.waitFirstElement(expect, for: self.viewModel.alertUnavailToUseService) {
            self.viewModel.preparePermission()
        }
        
        // then
        XCTAssertNotNil(void)
    }
    
    func testViewModel_whenAuthorizeStatusAlreadyRejected_moveCameraToDefaultLocation() {
        // given
        let expect = expectation(description: "권한 이미 거절했으면 -> 디폴트 위치로 카메라 이동")
        
        self.mockLocationUsecase.register(key: "checkHasPermission") {
            return Maybe<LocationServiceAccessPermission>.just(.rejected)
        }
        
        // when
        let moving = self.waitFirstElement(expect, for: self.viewModel.cameraPosition) {
            self.viewModel.preparePermission()
        }
        
        // then
        if case .default = moving {
            XCTAssert(true)
        } else {
            XCTFail("기대하는 카메라 위치가 아님")
        }
    }
    
    func testViewModel_whenAuthorizeStatusAlreadyRejected_alertUnavailToUseService() {
        // given
        let expect = expectation(description: "권한 이미 거절했으면 -> 서비스 이용 불가 알림")
        
        self.mockLocationUsecase.register(key: "checkHasPermission") {
            return Maybe<LocationServiceAccessPermission>.just(.rejected)
        }
        
        // when
        let void: Void? = self.waitFirstElement(expect, for: self.viewModel.alertUnavailToUseService) {
            self.viewModel.preparePermission()
        }
        
        // then
        XCTAssertNotNil(void)
    }
    
    func testViewModel_whenAuthorizeStatusRejected_emitEvent() {
        // given
        let expect = expectation(description: "권한 거절시에 서비스 이용불가 외부로 알림")
        
        self.mockLocationUsecase.register(key: "checkHasPermission") {
            return Maybe<LocationServiceAccessPermission>.just(.notDetermined)
        }
        self.mockLocationUsecase.register(key: "requestPermission") {
            return Maybe<Bool>.just(false)
        }
        
        // when
        let void: Void? = self.waitFirstElement(expect, for: self.viewModel.unavailToUseService) {
            self.viewModel.preparePermission()
        }
        
        // then
        XCTAssertNotNil(void)
    }
}

extension NearbyViewModelTests {
    
    class SpyRouter: NearbyRouting {
        
        
    }
}