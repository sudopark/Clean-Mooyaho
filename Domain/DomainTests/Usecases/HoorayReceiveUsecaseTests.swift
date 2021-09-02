//
//  HoorayReceiveUsecaseTests.swift
//  DomainTests
//
//  Created by sudo.park on 2021/05/15.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import UnitTestHelpKit

@testable import Domain


class HoorayReceiveUsecaseTests: BaseHoorayUsecaseTests { }


extension HoorayReceiveUsecaseTests {
    
    func testUsecase_loadNearbyRecentHoorays() {
        // given
        let expect = expectation(description: "근처에 있는 최근 후레이 조회")
        self.sharedStore.updateAuth(Auth(userID: "myID"))
        
        self.mockHoorayRepository.register(type: Maybe<[Hooray]>.self, key: "requestLoadNearbyRecentHoorays") {
            let hoorays: [Hooray] = (0..<10).map(Hooray.dummy(_:))
            return .just(hoorays)
        }
        
        // when
        let requestLoad = self.usecase.loadNearbyRecentHoorays(at: .init(latt: 0, long: 0))
        let hoorays = self.waitFirstElement(expect, for: requestLoad.asObservable()) { }
        
        // then
        XCTAssertEqual(hoorays?.count, 10)
    }
    
    func testUsecase_whenSendAckToNearbyHoorays_updateHooray() {
        // given
        let expect = expectation(description: "근처에 있는 후레이 조회 + ack 전송시에 후레이에 ackID 저장")
        self.sharedStore.updateAuth(Auth(userID: "myID"))
        
        self.mockHoorayRepository.called(key: "requestAckHooray") { _ in
            expect.fulfill()
        }
        
        self.mockHoorayRepository.register(type: Maybe<[Hooray]>.self, key: "requestLoadNearbyRecentHoorays") {
            let hoorays: [Hooray] = (0..<10).map(Hooray.dummy(_:))
            return .just(hoorays)
        }
        
        // when
        self.usecase.loadNearbyRecentHoorays(at: .init(latt: 0, long: 0))
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testUsecase_whenLoadNearbyRecentHoorays_notSendAckToMyHooray() {
        // given
        let expect = expectation(description: "근처에 있는 최근 후레이 조회해서 읽음처리시 내꺼에는 ack x")
        let myID = "pub:0"
        self.sharedStore.updateAuth(Auth(userID: myID))
        var acks: [HoorayAckMessage]?
        
        self.mockHoorayRepository.called(key: "requestAckHooray") { params in
            acks = params as? [HoorayAckMessage]
            expect.fulfill()
        }
        
        self.mockHoorayRepository.register(type: Maybe<[Hooray]>.self, key: "requestLoadNearbyRecentHoorays") {
            let hoorays: [Hooray] = (0..<10).map(Hooray.dummy(_:))
            return .just(hoorays)
        }
        
        // when
        self.usecase.loadNearbyRecentHoorays(at: .init(latt: 0, long: 0))
            .subscribe()
            .disposed(by: self.disposeBag)
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        let myAck = acks?.first(where: { $0.hoorayPublisherID == myID })
        XCTAssertEqual(acks?.count, 9)
        XCTAssertNil(myAck)
    }
    
    func testUsecase_loadHooray() {
        // given
        let expect = expectation(description: "hooray 조회")
        
        self.mockHoorayRepository.register(key: "requestLoadHooray") {
            return Maybe<Hooray>.just(Hooray.dummy(0))
        }
        
        // when
        let loading = self.usecase.loadHooray("some")
        let hooray = self.waitFirstElement(expect, for: loading.asObservable())
        
        // then
        XCTAssertNotNil(hooray)
    }
    
    func testUsecase_whenLoadHoorayDetailAndLocalExists_emitLocalAndRemoteHooray() {
        // given
        let expect = expectation(description: "hooray 상세내용 조회시에 local에 저장된값이 있으면 이를 먼저 방출하고 이후 remote에서 방출")
        expect.expectedFulfillmentCount = 2
        
        self.mockHoorayRepository.register(key: "fetchHoorayDetail") {  Maybe<HoorayDetail?>.just(HoorayDetail.dummy(0)) }
        self.mockHoorayRepository.register(key: "requestLoadHoorayDetail") {  Maybe<HoorayDetail>.just(HoorayDetail.dummy(0)) }
        
        // when
        let loading = self.usecase.loadHoorayHoorayDetail("some")
        let hoorays = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(hoorays.count, 2)
    }
    
    func testUsecase_whenLoadHoorayDetailWithoutLocalHooray_justEmitHoorayFromRemote() {
        // given
        let expect = expectation(description: "hooray 상세내용 조회시 로컬에 저장된 값이 없는경우 remote 조회결과만 반환")
        
        self.mockHoorayRepository.register(key: "fetchHoorayDetail") {  Maybe<HoorayDetail?>.just(nil) }
        self.mockHoorayRepository.register(key: "requestLoadHoorayDetail") { Maybe<HoorayDetail>.just(HoorayDetail.dummy(0)) }
        
        // when
        let loading = self.usecase.loadHoorayHoorayDetail("some")
        let hoorays = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(hoorays.count, 1)
    }
    
    func testUsecase_whenLoadHoorayDetailAndLoadCacneFails_ignore() {
        // given
        let expect = expectation(description: "hooray 상세내용 조회시 로컬조회시 발생한 에러는 무시하고 remote 조회결과만 반환")
        
        self.mockHoorayRepository.register(key: "fetchHoorayDetail") {  Maybe<HoorayDetail?>.error(ApplicationErrors.invalid) }
        self.mockHoorayRepository.register(key: "requestLoadHoorayDetail") { Maybe<HoorayDetail>.just(HoorayDetail.dummy(0)) }
        
        // when
        let loading = self.usecase.loadHoorayHoorayDetail("some")
        let hoorays = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(hoorays.count, 1)
    }
    
    func testUsecase_whenLoadHoorayDetailFromRemoteFail_emitError() {
        // given
        let expect = expectation(description: "hooray 상세내용 조회시 remote 조회 실패하면 실패처리")
        
        self.mockHoorayRepository.register(key: "fetchHoorayDetail") { Maybe<HoorayDetail?>.just(HoorayDetail.dummy(0)) }
        self.mockHoorayRepository.register(key: "requestLoadHoorayDetail") { Maybe<HoorayDetail>.error(ApplicationErrors.invalid) }
        
        // when
        let loading = self.usecase.loadHoorayHoorayDetail("some")
        let error = self.waitError(expect, for: loading)
        
        // then
        XCTAssertNotNil(error)
    }
}


extension HoorayReceiveUsecaseTests {
    
    func testUsecase_receiveNewHooray() {
        // given
        let expect = expectation(description: "새로운 후레이 수신")
        expect.expectedFulfillmentCount = 3
        
        
        // when
        let newHoorays = self.waitElements(expect, for: self.usecase.newReceivedHoorayMessage) {
            let newMessage: [NewHoorayMessage] = (0..<3).map{ .dummy($0) }
            newMessage.forEach {
                self.mockMessagingService.newMessage.onNext($0)
            }
        }
        
        // then
        XCTAssertEqual(newHoorays.count, 3)
    }
    
    func testUsecase_whenReceiveNewHooray_sendAck() {
        // given
        let expect = expectation(description: "새로운 후레이 수신시에 ack 처리")
        expect.expectedFulfillmentCount = 3
        
        self.sharedStore.updateAuth(Auth(userID: "myID"))
        
        self.mockHoorayRepository.called(key: "requestAckHooray") { _ in
            expect.fulfill()
        }
        
        self.usecase.newReceivedHoorayMessage
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // when
        let newMessage: [NewHoorayMessage] = (0..<3).map{ .dummy($0) }
        newMessage.forEach {
            self.mockMessagingService.newMessage.onNext($0)
        }
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}
