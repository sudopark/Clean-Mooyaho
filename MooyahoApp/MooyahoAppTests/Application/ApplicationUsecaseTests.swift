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
import UsecaseDoubles

@testable import Readmind


class ApplicationUsecaseTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var mockAuthUsecase: MockAuthUsecase!
    var mockMemberUsecase: MockMemberUsecase!
    var mockShareUsecase: StubShareItemUsecase!
    var usecase: ApplicationUsecaseImple!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.mockAuthUsecase = .init()
        self.mockMemberUsecase = .init()
        self.mockShareUsecase = .init()
        self.usecase = .init(authUsecase: self.mockAuthUsecase,
                             memberUsecase: self.mockMemberUsecase,
                             favoriteItemsUsecase: StubReadItemUsecase(),
                             shareUsecase: self.mockShareUsecase,
                             crashLogger: EmptyCrashLogger())
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.mockAuthUsecase = nil
        self.mockMemberUsecase = nil
        self.mockShareUsecase = nil
        self.usecase = nil
    }
}

// MARK: - trigger uploading user location

extension ApplicationUsecaseTests {
    
//    func testUsecase_whenAfterLaunchAndAuthLoadedAndHasLocationPermission_startUploadUserLocation() {
//        // given
//        let expect = expectation(description: "앱 시작 이후에 위치정보 접근 권한 있으면 업로드 시작")
//        
//        self.mockUserLocationUsecase.register(key: "checkHasPermission") {
//            return Maybe<LocationServiceAccessPermission>.just(.granted)
//        }
//        
//        self.mockUserLocationUsecase.called(key: "startUploadUserLocation") { _ in
//            expect.fulfill()
//        }
//        
//        // when
//        self.usecase.updateApplicationActiveStatus(.launched)
//        self.mockAuthUsecase.auth.onNext(Auth(userID: "some"))
//        
//        // then
//        self.wait(for: [expect], timeout: self.timeout)
//    }
//    
//    func testUsecase_whenAfterLanchedAndHasNoLocationPermission_notStartUploadUserLocation() {
//        // given
//        let expect = expectation(description: "앱 시작 이후에 위치정보 접근 권한 없으면 업로드 시작 안함")
//        expect.isInverted = true
//        
//        self.mockUserLocationUsecase.register(key: "checkHasPermission") {
//            return Maybe<LocationServiceAccessPermission>.just(.notDetermined)
//        }
//        
//        self.mockUserLocationUsecase.called(key: "startUploadUserLocation") { _ in
//            expect.fulfill()
//        }
//        
//        // when
//        self.usecase.updateApplicationActiveStatus(.launched)
//        self.mockAuthUsecase.auth.onNext(Auth(userID: "some"))
//        
//        // then
//        self.wait(for: [expect], timeout: self.timeout)
//    }
//    
//    func testUsecase_whenAfterLocationPermissionChangeToGrant_startUploadUserLocation() {
//        // given
//        let expect = expectation(description: "앱 실행중 위치권한이 실행중으로 바뀌면 업로드 시작")
//        self.mockUserLocationUsecase.register(key: "checkHasPermission") {
//            return Maybe<LocationServiceAccessPermission>.just(.notDetermined)
//        }
//        self.mockUserLocationUsecase.called(key: "startUploadUserLocation") { _ in
//            expect.fulfill()
//        }
//        
//        // when
//        self.usecase.updateApplicationActiveStatus(.launched)
//        self.mockAuthUsecase.auth.onNext(Auth(userID: "some"))
//        self.mockUserLocationUsecase.isAuthorizedSubject.onNext(true)
//        
//        // then
//        self.wait(for: [expect], timeout: self.timeout)
//    }
//    
//    func testUsecase_whenAfterEnterBackground_stopUploadUserLocation() {
//        // given
//        let expect = expectation(description: "앱 백그라운드 진입시 업로드 중지 요청")
//        self.mockUserLocationUsecase.register(key: "checkHasPermission") {
//            return Maybe<LocationServiceAccessPermission>.just(.granted)
//        }
//        self.mockUserLocationUsecase.called(key: "stopUplocationUserLocation") { _ in
//            expect.fulfill()
//        }
//        
//        // when
//        self.usecase.updateApplicationActiveStatus(.launched)
//        self.mockAuthUsecase.auth.onNext(Auth(userID: "some"))
//        self.usecase.updateApplicationActiveStatus(.background)
//        
//        // then
//        self.wait(for: [expect], timeout: self.timeout)
//    }
//    
//    func testUsecase_whenAfterEnterForgroundAgain_startUploadUserLocation() {
//        // given
//        let expect = expectation(description: "백그라운드 진입 이후에 업로드할 수 있으면 다시 업로드 시작")
//        expect.expectedFulfillmentCount = 2
//        
//        self.mockUserLocationUsecase.register(key: "checkHasPermission") {
//            return Maybe<LocationServiceAccessPermission>.just(.granted)
//        }
//        self.mockUserLocationUsecase.called(key: "startUploadUserLocation") { _ in
//            expect.fulfill()
//        }
//        
//        
//        // when
//        self.usecase.updateApplicationActiveStatus(.launched)
//        self.mockAuthUsecase.auth.onNext(Auth(userID: "some"))
//        self.usecase.updateApplicationActiveStatus(.background)
//        self.usecase.updateApplicationActiveStatus(.forground)
//        
//        // then
//        self.wait(for: [expect], timeout: self.timeout)
//    }
}


// MARK: - update user device info

extension ApplicationUsecaseTests {
    
//    func testUsecase_udpateIsOnline_byApplicaitonStatus() {
//        // given
//        let expect = expectation(description: "어플리케이션 상태에 때라 isOnline 상태 업데이트")
//        expect.expectedFulfillmentCount = 3
//        var isOnlineFlags = [Bool]()
//
//        self.mockMemberUsecase.called(key: "updateUserIsOnline") { args in
//            guard let flag = args as? Bool else { return }
//            isOnlineFlags.append(flag)
//            expect.fulfill()
//        }
//
//        // when
//        self.usecase.updateApplicationActiveStatus(.launched)
//        self.mockAuthUsecase.auth.onNext(Auth(userID: "some"))
//        self.usecase.updateApplicationActiveStatus(.background)
//        self.usecase.updateApplicationActiveStatus(.forground)
//        self.wait(for: [expect], timeout: self.timeout)
//
//        // then
//        XCTAssertEqual(isOnlineFlags, [true, false, true])
//    }
    
    func testUsecase_whenFCMTokenIsUpdated_uploadToken() {
        // given
        let expect = expectation(description: "fcm 토큰 업데이트시에 업로드")
        
        self.mockMemberUsecase.called(key: "updatePushToken") { _ in
            expect.fulfill()
        }
        
        // when
        self.mockMemberUsecase.currentMemberSubject.onNext(Member.init(uid: "some"))
        self.usecase.userFCMTokenUpdated(nil)
        self.usecase.userFCMTokenUpdated("new token")
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    private func veritySignInMemberDataRefreshCalled(_ expect: XCTestExpectation,
                                                     _ action: @escaping () -> Void) -> Bool {
        var memberRefreshed: Bool = false
        var sharingIDRefreshed: Bool = false
        self.mockMemberUsecase.called(key: "refreshMembers") { _ in
            memberRefreshed = true
            expect.fulfill()
        }
        
        self.mockShareUsecase.called(key: "refreshMySharingColletionIDs") { _ in
            sharingIDRefreshed = true
            expect.fulfill()
        }
        
        action()
        self.wait(for: [expect], timeout: self.timeout)
        
        return memberRefreshed && sharingIDRefreshed
    }
    
    private func setupSignIn(_ isSignIn: Bool) {
        self.mockMemberUsecase.currentMemberSubject
            .onNext(isSignIn ? Member.init(uid: "some") : nil)
    }
    
    func testUsecase_whenMemberSignInMemberStartApp_refreshSignInMemberData() {
        // given
        let expect = expectation(description: "로그인한 유저가 앱 시작하면 필요 데이터 갱신")
        expect.expectedFulfillmentCount = 2
        self.setupSignIn(true)
        
        // when
        let refreshed = self.veritySignInMemberDataRefreshCalled(expect) {
            self.usecase.updateApplicationActiveStatus(.launched)
        }
        
        // then
        XCTAssertEqual(refreshed, true)
    }
    
    func testUsecase_whenMemberSignOutAndStartApp_notRefreshSignInMemberData() {
        // given
        let expect = expectation(description: "로그인한 유저가 앱 시작하면 필요 데이터 갱신")
        expect.expectedFulfillmentCount = 2
        expect.isInverted = true
        self.setupSignIn(false)
        
        // when
        let refreshed = self.veritySignInMemberDataRefreshCalled(expect) {
            self.usecase.updateApplicationActiveStatus(.launched)
        }
        
        // then
        XCTAssertEqual(refreshed, false)
    }
    
    func testUsecase_whenSignoutUserBecomeSignIn_refreshRequireDatas() {
        // given
        let expect = expectation(description: "로그아웃상태였던 유저가 로그인하면 필요 데이터 갱신")
        expect.expectedFulfillmentCount = 2
        self.setupSignIn(false)
        
        // when
        let refreshed = self.veritySignInMemberDataRefreshCalled(expect) {
            self.usecase.updateApplicationActiveStatus(.launched)
            self.setupSignIn(true)
        }
        
        // then
        XCTAssertEqual(refreshed, true)
    }
    
    func testUsecase_whenSignInMemberEnterForground_refreshRequireData() {
        // given
        let expect = expectation(description: "로그인한 유저가 백그라운드갔다 포그라운드 다시 올라오면 필요 데이터 갱신")
        expect.expectedFulfillmentCount = 2
        self.setupSignIn(true)
        self.usecase.updateApplicationActiveStatus(.launched)
        
        
        // when
        let refreshed = self.veritySignInMemberDataRefreshCalled(expect) {
            self.usecase.updateApplicationActiveStatus(.background)
            self.usecase.updateApplicationActiveStatus(.forground)
        }
        
        // then
        XCTAssertEqual(refreshed, true)
    }
    
    func testUsecase_whenSignOutMemberEnterForground_notRefreshRequireData() {
        // given
        let expect = expectation(description: "로그아웃 멤버는 백그라운드갔다 포그라운드 다시 올라와도 필요 데이터 갱신 안함")
        expect.expectedFulfillmentCount = 2
        expect.isInverted = true
        self.setupSignIn(false)
        self.usecase.updateApplicationActiveStatus(.launched)
        
        
        // when
        let refreshed = self.veritySignInMemberDataRefreshCalled(expect) {
            self.usecase.updateApplicationActiveStatus(.background)
            self.usecase.updateApplicationActiveStatus(.forground)
        }
        
        // then
        XCTAssertEqual(refreshed, false)
    }
}


extension ApplicationUsecaseTests {
    
    func testUsecase_loadLastSignInAccountInfo() {
        // given
        let expect = expectation(description: "마지막 로그인한 계정정보 로드")
        
        self.mockAuthUsecase.register(key: "loadLastSignInAccountInfo") {
            return Maybe<(auth: Auth, member: Member?)>.just((Auth(userID: "some"), nil))
        }
        
        // when
        let requestLoad = self.usecase.loadLastSignInAccountInfo()
        let accountInfo = self.waitFirstElement(expect, for: requestLoad.asObservable())
        
        // then
        XCTAssertNotNil(accountInfo)
    }
}


private class EmptyCrashLogger: CrashLogger {
    
    func setupUserIdentifier(_ identifier: String) { }
    
    func setupValue(_ value: Any, key: String) { }
    
    func log(_ message: String) { }
}
