//
//  MemberUsecaseTests.swift
//  DomainTests
//
//  Created by sudo.park on 2021/05/15.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import UnitTestHelpKit

@testable import Domain


class MemberUsecaseTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var store: SharedDataStoreServiceImple!
    var stubRepository: StubMemberRepository!
    var usecase: MemberUsecaseImple!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = .init()
        self.stubRepository = .init()
        self.store = .init()
        self.usecase = MemberUsecaseImple(memberRepository: self.stubRepository, sharedDataService: self.store)
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.stubRepository = nil
        self.store = nil
        self.usecase = nil
        super.tearDown()
    }
}


extension MemberUsecaseTests {
    
    func testUsecase_updateUserIsOnlneStatus() {
        // given
        let expect = expectation(description: "유저 온라인 여부 업데이트")
        
        self.stubRepository.called(key: "requestUpdateUserPresence") { args in
            if let isOnline = args as? Bool, isOnline {
                expect.fulfill()
            }
        }
        
        
        // when
        self.usecase.updateUserIsOnline(0, isOnline: true)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
//    func testUsecase_loadNearbyUserPresences() {
//        // given
//        let expect = expectation(description: "주변에 존재하는 유저 조회")
//
//        self.stubRepository.register(key: "requestLoadNearbyUsers") {
//            return Maybe<[UserPresence]>.just([UserPresence(userID: "dummy", lastLocation: .init(lattitude: 0, longitude: 0, timeStamp: 0))])
//        }
//
//        // when
//        let requestLoad = self.usecase.loadNearbyUsers(at: .init(latt: 0, long: 0))
//        let presences = self.waitFirstElement(expect, for: requestLoad.asObservable()) { }
//
//        // then
//        XCTAssertEqual(presences?.count, 1)
//    }
    
    func testUsecase_whenLoadCurrentMemberShip_existOnSharedStore() {
        // given
        let expect = expectation(description: "공유 저장소에 멤버쉽 존재하는 경우 로드")
        self.store.save(.membership, MemberShip())
        
        // when
        let requestLoad = self.usecase.loadCurrentMembership()
        let membership = self.waitFirstElement(expect, for: requestLoad.asObservable()) { }
        
        // then
        XCTAssertNotNil(membership)
    }
    
    func testUsecase_whenLoadCurrentMemberShip_notExistOnSharedStore() {
        // given
        let expect = expectation(description: "공유 저장소에 멤버쉽 존재 안하는 경우 로드")
        self.store.save(.currentMember, Member(uid: "dummy"))
        self.stubRepository.register(key: "requestLoadMembership") {
            return Maybe<MemberShip>.just(.init())
        }
        
        // when
        let requestLoad = self.usecase.loadCurrentMembership()
        let membership = self.waitFirstElement(expect, for: requestLoad.asObservable()) { }
        
        // then
        XCTAssertNotNil(membership)
    }
}
