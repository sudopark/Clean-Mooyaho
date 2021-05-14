//
//  HoorayPublisherUsecaseTests.swift
//  DomainTests
//
//  Created by sudo.park on 2021/05/15.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import UnitTestHelpKit

@testable import Domain


class HoorayPublisherUsecaseTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var stubMemberRepository: StubMemberRepository!
    var sharedStore: SharedDataStoreServiceImple!
    var stubHoorayRepository: StubHoorayRepository!
    var usecase: HoorayPublishUsecaseImple!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = .init()
        self.stubMemberRepository = .init()
        self.stubHoorayRepository = .init()
        self.sharedStore = .init()
        let memberUsecase = MemberUsecaseImple(memberRepository: self.stubMemberRepository,
                                               sharedDataService: self.sharedStore)
        self.usecase = .init(memberUsecase: memberUsecase,
                             hoorayRepository: self.stubHoorayRepository)
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.stubMemberRepository = nil
        self.stubHoorayRepository = nil
        self.usecase = nil
        super.tearDown()
    }
}


// MARK: - test check publish hoorayable

extension HoorayPublisherUsecaseTests {
    
    func testUsecase_whenLatestHoorayNotExists_availToPublishHooray() {
        // given
        let expect = expectation(description: "한번도 후레이 쏜적 없으면 쏠수있음")
        self.stubMemberShip()
        self.stubHoorayRepository.register(type: Maybe<LatestHooray?>.self, key: "requestLoadLatestHooray") {
            return .just(nil)
        }
        
        // when
        let requestCheck = self.usecase.isAvailToPublish("dummy")
        let isAvail = self.waitFirstElement(expect, for: requestCheck.asObservable()) { }
        
        // then
        XCTAssertEqual(isAvail, true)
    }
    
    private func stubMemberShip() {
        self.sharedStore.save(.currentMember, Member(uid: "dummy"))
        self.sharedStore.save(.membership, MemberShip())
    }
    
    func testUsecase_whenLatestHoorayExistsWithInLimit_unavailToPublishHooray() {
        // given
        let expect = expectation(description: "마지막 후레이 이후 일정시간이 지나지 않은경우 후레이 불가")
        
        self.stubMemberShip()
        self.stubHoorayRepository.register(type: Maybe<LatestHooray?>.self, key: "requestLoadLatestHooray") {
            let defCooltime = HoorayPublishPolicy.defaultCooltime
            let latest = LatestHooray("latest", TimeSeconds.now() - defCooltime.asTimeInterval() + 5)
            return .just(latest)
        }
        
        // when
        let requestCheck = self.usecase.isAvailToPublish("dummy")
        let isAvail = self.waitFirstElement(expect, for: requestCheck.asObservable()) { }
        
        // then
        XCTAssertEqual(isAvail, false)
    }
    
    func testUsecase_whenLatestNotTooSoon_availToPublish() {
        // given
        let expect = expectation(description: "마지막 후레이 이후 일정시간이 지났다면 후레이 가능")
        
        self.stubMemberShip()
        self.stubHoorayRepository.register(type: Maybe<LatestHooray?>.self, key: "requestLoadLatestHooray") {
            let defCooltime = HoorayPublishPolicy.defaultCooltime.asTimeInterval()
            let latest = LatestHooray("latest", TimeSeconds.now() - defCooltime * 10)
            return .just(latest)
        }
        
        // when
        let requestCheck = self.usecase.isAvailToPublish("dummy")
        let isAvail = self.waitFirstElement(expect, for: requestCheck.asObservable()) { }
        
        // then
        XCTAssertEqual(isAvail, true)
    }
    
    func testUsecase_whenTryToHoorayFailtoLoadMemberShipInfo_failToPublish() {
        // given
        let expect = expectation(description: "후레이 발행 이전에 멤버쉽 조회에 실패하면 실패처리")
        
        self.stubHoorayRepository.register(type: Maybe<LatestHooray?>.self, key: "requestLoadLatestHooray") {
            let defCooltime = HoorayPublishPolicy.defaultCooltime.asTimeInterval()
            let latest = LatestHooray("latest", TimeSeconds.now() - defCooltime * 10)
            return .just(latest)
        }
        self.stubMemberRepository.register(key: "requestLoadMembership") {
            return Maybe<MemberShip>.error(ApplicationErrors.noAuth)
        }
        
        // when
        let requestCheck = self.usecase.isAvailToPublish("dummy")
        let error = self.waitError(expect, for: requestCheck.asObservable()) { }
        
        // then
        XCTAssertNotNil(error)
    }
}


// MARK: - test publish hooray

extension HoorayPublisherUsecaseTests {
    
    func testUsecase_publishNewHooray() {
        // given
        let expect = expectation(description: "새로운 후레이 등록")
        self.stubHoorayRepository.register(key: "requestPublishHooray") {
            return Maybe<Hooray>.just(Hooray.dummy(0))
        }
        
        // when
        let newForm = NewHoorayForm(publisherID: "dummy")
        let requestPublish = self.usecase.publish(newHooray: newForm, withNewPlace: nil)
        let newHooray = self.waitFirstElement(expect, for: requestPublish.asObservable()) {}
        
        // then
        XCTAssertNotNil(newHooray)
    }
    
    func testUsecase_publishNewHooray_withNewPlace() {
        // given
        let expect = expectation(description: "신규 등록할 장소와 함께 새로운 후레이 등록")
        self.stubHoorayRepository.register(key: "requestPublishHooray") {
            return Maybe<Hooray>.just(Hooray.dummy(0))
        }
        
        // when
        let newForm = NewHoorayForm(publisherID: "dummy")
        let newPlaceForm = NewPlaceForm(reporterID: "dummy", infoProvider: .userDefine)
        let requestPublish = self.usecase.publish(newHooray: newForm, withNewPlace: newPlaceForm)
        let newHooray = self.waitFirstElement(expect, for: requestPublish.asObservable()) {}
        
        // then
        XCTAssertNotNil(newHooray)
    }
}
