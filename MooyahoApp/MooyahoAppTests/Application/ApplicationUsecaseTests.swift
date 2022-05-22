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
    private var mockAuthUsecase: MockAuthUsecase!
    private var mockReadItemUsecase: MockReadItemUsecase!
    private var spyCategoryUsecase: SpyCategoryUsecase!
    private var mockMemberUsecase: MockMemberUsecase!
    private var mockShareUsecase: StubShareItemUsecase!
    private var usecase: ApplicationUsecaseImple!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.mockAuthUsecase = .init()
        self.mockReadItemUsecase = .init()
        self.spyCategoryUsecase = .init()
        self.mockMemberUsecase = .init()
        self.mockShareUsecase = .init()
        self.usecase = .init(authUsecase: self.mockAuthUsecase,
                             memberUsecase: self.mockMemberUsecase,
                             readItemUsecase: self.mockReadItemUsecase,
                             readItemCategoryUsecase: self.spyCategoryUsecase,
                             shareUsecase: self.mockShareUsecase,
                             crashLogger: EmptyCrashLogger())
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.mockAuthUsecase = nil
        self.mockReadItemUsecase = nil
        self.spyCategoryUsecase = nil
        self.mockMemberUsecase = nil
        self.mockShareUsecase = nil
        self.usecase = nil
    }
}

// MARK: - update user device info

extension ApplicationUsecaseTests {
    
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
    
    private func signInOrNotMocking(_ isSignIn: Bool) {
        let member: Member? = isSignIn ? Member(uid: "some") : nil
        self.mockAuthUsecase.register(key: "loadLastSignInAccountInfo") {
            return Maybe<(auth: Auth, member: Member?)>.just((Auth(userID: "some"), member))
        }
    }
    
    func testUsecase_loadLastSignInAccountInfo() {
        // given
        let expect = expectation(description: "마지막 로그인한 계정정보 로드")
        self.signInOrNotMocking(false)
        
        // when
        let requestLoad = self.usecase.loadLastSignInAccountInfo()
        let accountInfo = self.waitFirstElement(expect, for: requestLoad.asObservable())
        
        // then
        XCTAssertNotNil(accountInfo)
    }
    
    func testUsecase_whenLoadLastSignInAccountInfoWithoutSignInAndNotAddedWelcomeItemAndItemsEmpty_addWelcomeItem() {
        // given
        let expect = expectation(description: "로그인 안한 유저 + 웰컴아이템 추가 안되어있는경우 + 저장된 아이템이 없다면 웰컴아이템 추가")
        self.signInOrNotMocking(false)
        self.mockReadItemUsecase.myItemsMocking([])
        self.mockReadItemUsecase.didWelcomeItemAddedMocking(false)
        
        // when
        let request = self.usecase.loadLastSignInAccountInfo()
        let _ = self.waitFirstElement(expect, for: request.asObservable())
        
        // then
        XCTAssertEqual(self.mockReadItemUsecase.didWelComeItemAdded(), true)
        XCTAssertEqual(self.mockReadItemUsecase.didUpdateedLinkItem?.isWelcomeItem, true)
        XCTAssertEqual(self.spyCategoryUsecase.didUpdatedCategories?.count, 3)
    }
    
    func testUsecase_whenLoadLastSignInAccountInfoWithoutSignInAndItemsEmptyButAddWelcomeItemBefore_notAddWelcomeItem() {
        // given
        let expect = expectation(description: "로그인 안한 유저 + 저장된 아이템 없지만 + 웰컴아이템 추가한적 있으면 웰컴아이템 추가 안함")
        self.signInOrNotMocking(false)
        self.mockReadItemUsecase.myItemsMocking([])
        self.mockReadItemUsecase.didWelcomeItemAddedMocking(true)
        
        // when
        let request = self.usecase.loadLastSignInAccountInfo()
        let _ = self.waitFirstElement(expect, for: request.asObservable())
        
        // then
        XCTAssertNil(self.mockReadItemUsecase.didUpdateedLinkItem?.isWelcomeItem)
    }
    
    func testUsecase_whenSignoutButReadItemsNotEmpty_notAddWelcomeItem() {
        // given
        let expect = expectation(description: "로그인 안한상태이지만 아이템들이 있으면 웰컴아이템 추가 안함")
        self.signInOrNotMocking(false)
        self.mockReadItemUsecase.myItemsMocking([ReadLink.dummy(0)])
        self.mockReadItemUsecase.didWelcomeItemAddedMocking(false)
        
        // when
        let request = self.usecase.loadLastSignInAccountInfo()
        let _ = self.waitFirstElement(expect, for: request.asObservable())
        
        // then
        XCTAssertNil(self.mockReadItemUsecase.didUpdateedLinkItem?.isWelcomeItem)
    }
}


private class EmptyCrashLogger: CrashLogger {
    
    func setupUserIdentifier(_ identifier: String) { }
    
    func setupValue(_ value: Any, key: String) { }
    
    func log(_ message: String) { }
}


private extension ApplicationUsecaseTests {
    
    final class MockReadItemUsecase: StubReadItemUsecase {
        
        func didWelcomeItemAddedMocking(_ isAdded: Bool) {
            self.scenario.isWelcomeItemAddedBefore = isAdded
        }
        
        func myItemsMocking(_ items: [ReadItem]) {
            self.scenario.myItems = .success(items)
        }
        
        var didUpdateedLinkItem: ReadLink?
        override func updateLink(_ link: ReadLink) -> Maybe<Void> {
            return super.updateLink(link)
                .do(onNext: {
                    self.didUpdateedLinkItem = link
                })
        }
    }
    
    final class SpyCategoryUsecase: StubItemCategoryUsecase {
        
        var didUpdatedCategories: [ItemCategory]?
        override func updateCategories(_ categories: [ItemCategory]) -> Maybe<Void> {
            self.didUpdatedCategories = categories
            return super.updateCategories(categories)
        }
    }
}
