//
//  ApplicationUsecaseTests.swift
//  MooyahoAppTests
//
//  Created by sudo.park on 2021/05/25.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit
import StubUsecases

@testable import MooyahoApp


class ApplicationUsecaseTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var stubAuthUsecase: StubAuthUsecase!
    var stubMemberUsecase: StubMemberUsecase!
    var stubLocationUsecase: StubUserLocationUsecase!
    var usecase: ApplicationUsecaseImple!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.stubAuthUsecase = .init()
        self.stubMemberUsecase = .init()
        self.stubLocationUsecase = .init()
        self.usecase = .init(authUsecase: self.stubAuthUsecase,
                             memberUsecase: self.stubMemberUsecase,
                             locationUsecase: self.stubLocationUsecase)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.stubAuthUsecase = nil
        self.stubMemberUsecase = nil
        self.stubLocationUsecase = nil
        self.usecase = nil
    }
}

// MARK: - trigger uploading user location

extension ApplicationUsecaseTests {
    
    func testUsecase_whenAfterLaunchAndAuthLoadedAndHasLocationPermission_startUploadUserLocation() {
        // given
        let expect = expectation(description: "앱 시작 이후에 위치정보 접근 권한 있으면 업로드 시작")
        
        self.stubLocationUsecase.register(key: "checkHasPermission") {
            return Maybe<LocationServiceAccessPermission>.just(.granted)
        }
        
        self.stubLocationUsecase.called(key: "startUploadUserLocation") { _ in
            expect.fulfill()
        }
        
        // when
        self.usecase.updateApplicationActiveStatus(.launched)
        self.stubAuthUsecase.stubAuth.onNext(Auth(userID: "some"))
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testUsecase_whenAfterLanchedAndHasNoLocationPermission_notStartUploadUserLocation() {
        // given
        let expect = expectation(description: "앱 시작 이후에 위치정보 접근 권한 없으면 업로드 시작 안함")
        expect.isInverted = true
        
        self.stubLocationUsecase.register(key: "checkHasPermission") {
            return Maybe<LocationServiceAccessPermission>.just(.notDetermined)
        }
        
        self.stubLocationUsecase.called(key: "startUploadUserLocation") { _ in
            expect.fulfill()
        }
        
        // when
        self.usecase.updateApplicationActiveStatus(.launched)
        self.stubAuthUsecase.stubAuth.onNext(Auth(userID: "some"))
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testUsecase_whenAfterLocationPermissionChangeToGrant_startUploadUserLocation() {
        // given
        let expect = expectation(description: "앱 실행중 위치권한이 실행중으로 바뀌면 업로드 시작")
        self.stubLocationUsecase.register(key: "checkHasPermission") {
            return Maybe<LocationServiceAccessPermission>.just(.notDetermined)
        }
        self.stubLocationUsecase.called(key: "startUploadUserLocation") { _ in
            expect.fulfill()
        }
        
        // when
        self.usecase.updateApplicationActiveStatus(.launched)
        self.stubAuthUsecase.stubAuth.onNext(Auth(userID: "some"))
        self.stubLocationUsecase.stubIsAuthorized.onNext(true)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testUsecase_whenAfterEnterBackground_stopUploadUserLocation() {
        // given
        let expect = expectation(description: "앱 백그라운드 진입시 업로드 중지 요청")
        self.stubLocationUsecase.register(key: "checkHasPermission") {
            return Maybe<LocationServiceAccessPermission>.just(.granted)
        }
        self.stubLocationUsecase.called(key: "stopUplocationUserLocation") { _ in
            expect.fulfill()
        }
        
        // when
        self.usecase.updateApplicationActiveStatus(.launched)
        self.stubAuthUsecase.stubAuth.onNext(Auth(userID: "some"))
        self.usecase.updateApplicationActiveStatus(.background)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testUsecase_whenAfterEnterForgroundAgain_startUploadUserLocation() {
        // given
        let expect = expectation(description: "백그라운드 진입 이후에 업로드할 수 있으면 다시 업로드 시작")
        expect.expectedFulfillmentCount = 2
        
        self.stubLocationUsecase.register(key: "checkHasPermission") {
            return Maybe<LocationServiceAccessPermission>.just(.granted)
        }
        self.stubLocationUsecase.called(key: "startUploadUserLocation") { _ in
            expect.fulfill()
        }
        
        
        // when
        self.usecase.updateApplicationActiveStatus(.launched)
        self.stubAuthUsecase.stubAuth.onNext(Auth(userID: "some"))
        self.usecase.updateApplicationActiveStatus(.background)
        self.usecase.updateApplicationActiveStatus(.forground)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}


// MARK: - update user is online status

extension ApplicationUsecaseTests {
    
    func testUsecase_udpateIsOnline_byApplicaitonStatus() {
        // given
        let expect = expectation(description: "어플리케이션 상태에 때라 isOnline 상태 업데이트")
        expect.expectedFulfillmentCount = 3
        var isOnlineFlags = [Bool]()
        
        self.stubMemberUsecase.called(key: "updateUserIsOnline") { args in
            guard let flag = args as? Bool else { return }
            isOnlineFlags.append(flag)
            expect.fulfill()
        }
        
        // when
        self.usecase.updateApplicationActiveStatus(.launched)
        self.stubAuthUsecase.stubAuth.onNext(Auth(userID: "some"))
        self.usecase.updateApplicationActiveStatus(.background)
        self.usecase.updateApplicationActiveStatus(.forground)
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(isOnlineFlags, [true, false, true])
    }
}


extension ApplicationUsecaseTests {
    
    func testUsecase_loadLastSignInAccountInfo() {
        // given
        let expect = expectation(description: "마지막 로그인한 계정정보 로드")
        
        self.stubAuthUsecase.register(key: "loadLastSignInAccountInfo") {
            return Maybe<(auth: Auth, member: Member?)>.just((Auth(userID: "some"), nil))
        }
        
        // when
        let requestLoad = self.usecase.loadLastSignInAccountInfo()
        let accountInfo = self.waitFirstElement(expect, for: requestLoad.asObservable())
        
        // then
        XCTAssertNotNil(accountInfo)
    }
}
