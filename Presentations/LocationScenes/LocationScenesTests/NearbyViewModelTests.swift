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

@testable import LocationScenes


class NearbyViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var stubLocationUsecase: StubUserLocationUsecase!
    var spyRouter: SpyRouter!
    var viewModel: NearbyViewModelImple!
    
    override func setUpWithError() throws {
        self.disposeBag = DisposeBag()
        self.stubLocationUsecase = .init()
        self.spyRouter = .init()
        self.viewModel = NearbyViewModelImple(locationUsecase: self.stubLocationUsecase,
                                              router: self.spyRouter,
                                              listener: { _ in })
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.stubLocationUsecase = nil
        self.spyRouter = nil
        self.viewModel = nil
    }
}


extension NearbyViewModelTests {
    
    func testViewModel_whenHasNoAuthorixed_moveCameraToDefaultLocation() {
        // given
        let expect = expectation(description: "최초에 권한여부 조회해서 승인받지 않은 상태라면 디폴트위치로 카메라 이동")
        
        self.stubLocationUsecase.register(key: "checkHasPermission") {
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
        
        self.stubLocationUsecase.register(key: "checkHasPermission") {
            return Maybe<LocationServiceAccessPermission>.just(.notDetermined)
        }
        self.stubLocationUsecase.register(key: "requestPermission") {
            return Maybe<Bool>.just(true)
        }
        self.stubLocationUsecase.register(key: "fetchUserLocation") {
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
        
        self.stubLocationUsecase.register(key: "checkHasPermission") {
            return Maybe<LocationServiceAccessPermission>.just(.notDetermined)
        }
        self.stubLocationUsecase.register(key: "requestPermission") {
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
        
        self.stubLocationUsecase.register(key: "checkHasPermission") {
            return Maybe<LocationServiceAccessPermission>.just(.notDetermined)
        }
        self.stubLocationUsecase.register(key: "requestPermission") {
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
        
        self.stubLocationUsecase.register(key: "checkHasPermission") {
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
        
        self.stubLocationUsecase.register(key: "checkHasPermission") {
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
        self.viewModel = .init(locationUsecase: self.stubLocationUsecase, router: self.spyRouter) { event in
            guard case .unavailToUseService = event else { return }
            expect.fulfill()
        }
        
        self.stubLocationUsecase.register(key: "checkHasPermission") {
            return Maybe<LocationServiceAccessPermission>.just(.notDetermined)
        }
        self.stubLocationUsecase.register(key: "requestPermission") {
            return Maybe<Bool>.just(false)
        }
        
        // when
        self.viewModel.preparePermission()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}

extension NearbyViewModelTests {
    
    class SpyRouter: NearbyRouting {
        
        
    }
}
