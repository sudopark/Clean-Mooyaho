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


class HoorayPublisherUsecaseTests: BaseHoorayUsecaseTests { }


// MARK: - test check publish hoorayable

extension HoorayPublisherUsecaseTests {
    
    private func stubMemberShip() {
        let dummyMember = Member(uid: "dummy", nickName: "hi", icon: nil)
        self.sharedStore.save(Member.self, key: .currentMember, dummyMember)
        self.sharedStore.save(MemberShip.self, key: .membership, MemberShip())
    }
    
    func testUsecase_whenLatestHoorayNotExists_availToPublishHooray() {
        // given
        let expect = expectation(description: "한번도 후레이 쏜적 없으면 쏠수있음")
        self.stubMemberShip()
        self.mockHoorayRepository.register(type: Maybe<LatestHooray?>.self, key: "fetchLatestHooray") {
            return .just(nil)
        }
        self.mockHoorayRepository.register(type: Maybe<LatestHooray?>.self, key: "requestLoadLatestHooray") {
            return .just(nil)
        }
        
        // when
        let requestCheck = self.usecase.isAvailToPublish()
        let isAvail: Void? = self.waitFirstElement(expect, for: requestCheck.asObservable()) { }
        
        // then
        XCTAssertNotNil(isAvail)
    }
    
    func testUsecase_whenTooSoonLatestHoorayExistsAtLocal_unavailToPublish() {
        // given
        let expect = expectation(description: "로컬에 최근에 발행한 후레이가 있으면 새로 생성 불가")
        self.stubMemberShip()
        self.mockHoorayRepository.register(type: Maybe<LatestHooray?>.self, key: "fetchLatestHooray") {
            let defCooltime = HoorayPublishPolicy.defaultCooltime
            let latest = LatestHooray("latest", TimeStamp.now() - defCooltime.asTimeInterval() + 5)
            return .just(latest)
        }
        
        // when
        let requestCheck = self.usecase.isAvailToPublish()
        let error = self.waitError(expect, for: requestCheck.asObservable())
        
        // then
        if let appError = error as? ApplicationErrors, case .shouldWaitPublishHooray = appError {
            XCTAssert(true)
        } else {
            XCTFail("기대하는 에러가 아님")
        }
    }
    
    func testUsecase_whenLatestHoorayExistsWithInLimit_unavailToPublishHooray() {
        // given
        let expect = expectation(description: "마지막 후레이 이후 일정시간이 지나지 않은경우 후레이 불가")
        
        self.stubMemberShip()
        self.mockHoorayRepository.register(type: Maybe<LatestHooray?>.self, key: "fetchLatestHooray") {
            return .just(nil)
        }
        self.mockHoorayRepository.register(type: Maybe<LatestHooray?>.self, key: "requestLoadLatestHooray") {
            let defCooltime = HoorayPublishPolicy.defaultCooltime
            let latest = LatestHooray("latest", TimeStamp.now() - defCooltime.asTimeInterval() + 5)
            return .just(latest)
        }
        
        // when
        let requestCheck = self.usecase.isAvailToPublish()
        let error = self.waitError(expect, for: requestCheck.asObservable())
        
        // then
        if let appError = error as? ApplicationErrors, case .shouldWaitPublishHooray = appError {
            XCTAssert(true)
        } else {
            XCTFail("기대하는 에러가 아님")
        }
    }
    
    func testUsecase_whenLatestNotTooSoon_availToPublish() {
        // given
        let expect = expectation(description: "마지막 후레이 이후 일정시간이 지났다면 후레이 가능")
        
        self.stubMemberShip()
        self.mockHoorayRepository.register(type: Maybe<LatestHooray?>.self, key: "fetchLatestHooray") {
            return .just(nil)
        }
        self.mockHoorayRepository.register(type: Maybe<LatestHooray?>.self, key: "requestLoadLatestHooray") {
            let defCooltime = HoorayPublishPolicy.defaultCooltime.asTimeInterval()
            let latest = LatestHooray("latest", TimeStamp.now() - defCooltime * 10)
            return .just(latest)
        }
        
        // when
        let requestCheck = self.usecase.isAvailToPublish()
        let isAvail: Void? = self.waitFirstElement(expect, for: requestCheck.asObservable()) { }
        
        // then
        XCTAssertNotNil(isAvail)
    }
    
    func testUsecase_whenTryToHoorayButNotSignedIn_returnError() {
        // given
        let expect = expectation(description: "후레이 시도시 로그인 안되어있으면 에러")
        
        // when
        let requestCheck = self.usecase.isAvailToPublish()
        let error = self.waitError(expect, for: requestCheck.asObservable())
        
        // then
        guard let appError = error as? ApplicationErrors, case .sigInNeed = appError else {
            XCTFail("기대하는 에러가 아님")
            return
        }
        XCTAssert(true)
    }
    
    func testUsecase_whenTryToHoorayButNotSetupUserProfileYet_returnError() {
        // given
        let expect = expectation(description: "후레이 시도시 유저 프로필 미입력 상태면 에러")
        
        let emptyMember = Member(uid: "dummy")
        self.sharedStore.update(Member.self, key: SharedDataKeys.currentMember.rawValue, value: emptyMember)
        
        // when
        let requestCheck = usecase.isAvailToPublish()
        let error = self.waitError(expect, for: requestCheck.asObservable())
        
        // then
        XCTAssertEqual(emptyMember.isProfileSetup, false)
        guard let appError = error as? ApplicationErrors, case .profileNotSetup = appError else {
            XCTFail("기대하는 에러가 아님")
            return
        }
        XCTAssert(true)
    }
    
    func testUsecase_whenTryToHoorayFailtoLoadMemberShipInfo_failToPublish() {
        // given
        let expect = expectation(description: "후레이 발행 이전에 멤버쉽 조회에 실패하면 실패처리")
        
        self.mockHoorayRepository.register(type: Maybe<LatestHooray?>.self, key: "fetchLatestHooray") {
            return .just(nil)
        }
        self.mockHoorayRepository.register(type: Maybe<LatestHooray?>.self, key: "requestLoadLatestHooray") {
            let defCooltime = HoorayPublishPolicy.defaultCooltime.asTimeInterval()
            let latest = LatestHooray("latest", TimeStamp.now() - defCooltime * 10)
            return .just(latest)
        }
        self.mockMemberRepository.register(key: "requestLoadMembership") {
            return Maybe<MemberShip>.error(ApplicationErrors.sigInNeed)
        }
        
        // when
        let requestCheck = usecase.isAvailToPublish()
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
        self.mockHoorayRepository.register(key: "requestPublishHooray") {
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
        self.mockHoorayRepository.register(key: "requestPublishHooray") {
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
    
    func testUsecase_whenAfterPublishNewHooray_emitEvent() {
        // given
        let expect = expectation(description: "새로운 후레이 발급 이후에 이벤트 방출")
        self.mockHoorayRepository.register(key: "requestPublishHooray") {
            return Maybe<Hooray>.just(Hooray.dummy(0))
        }
        
        // when
        let newHooray = self.waitFirstElement(expect, for: self.usecase.newHoorayPublished) {
            let newForm = NewHoorayForm(publisherID: "dummy")
            self.usecase.publish(newHooray: newForm, withNewPlace: nil)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        // then
        XCTAssertNotNil(newHooray)
    }
}


// MARK: - test recieve hooray ack and reactions

extension HoorayPublisherUsecaseTests {
    
    func testUsecase_receiveHoorayAck() {
        // given
        let expect = expectation(description: "후레이 ack 수신")
        expect.expectedFulfillmentCount = 3
        
        // when
        let acks = self.waitElements(expect, for: self.usecase.receiveHoorayAck) {
            (0..<3).forEach { int in
                let message = HoorayAckMessage(hoorayID: "id", publisherID: "pub", ackUserID: "id:\(int)")
                self.mockMessagingService.newMessage.onNext(message)
            }
        }
        
        // then
        XCTAssertEqual(acks.count, 3)
    }
    
    func testUsecase_receiveHoorayReactions() {
        // given
        let expect = expectation(description: "후레이 리엑션 수신")
        expect.expectedFulfillmentCount = 3
        
        // when
        let reactions = self.waitElements(expect, for: self.usecase.receiveHoorayReaction) {
            (0..<3).forEach { int in
                let info = HoorayReaction.ReactionInfo(reactMemberID: "res:\(int)", icon: .emoji("😾"), reactAt: 0)
                let message = HoorayReactionMessage(hoorayID: "id", publisherID: "pub", reactionInfo: info)
                self.mockMessagingService.newMessage.onNext(message)
            }
        }
        
        // then
        XCTAssertEqual(reactions.count, 3)
    }
}
