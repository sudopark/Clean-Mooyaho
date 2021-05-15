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
                self.stubMessagingService.stubNewMessage.onNext(message)
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
                self.stubMessagingService.stubNewMessage.onNext(message)
            }
        }
        
        // then
        XCTAssertEqual(reactions.count, 3)
    }
}
