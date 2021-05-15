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
        
        self.stubHoorayRepository.register(type: Maybe<[Hooray]>.self, key: "requestLoadNearbyRecentHoorays") {
            let hoorays: [Hooray] = (0..<10).map(Hooray.dummy(_:))
            return .just(hoorays)
        }
        
        // when
        let requestLoad = self.usecase.loadNearbyRecentHoorays("myID", at: .init(latt: 0, long: 0))
        let hoorays = self.waitFirstElement(expect, for: requestLoad.asObservable()) { }
        
        // then
        XCTAssertEqual(hoorays?.count, 10)
    }
    
    func testUsecase_whenLoadNearbyRecentHoorays_sendAckToNotYetAckedMessages() {
        // given
        let expect = expectation(description: "근처에 있는 최근 후레이 조회")
        expect.expectedFulfillmentCount = 5
        
        self.stubMessagingService.called(key: "sendMessage") { _ in
            expect.fulfill()
        }
        
        self.stubHoorayRepository.register(type: Maybe<[Hooray]>.self, key: "requestLoadNearbyRecentHoorays") {
            let hoorays: [Hooray] = (0..<10).map(Hooray.dummy(_:))
                .enumerated().map { offset, hry -> Hooray in
                    var hry = hry
                    hry.ackUserIDs = offset % 2 == 0 ? [.init(ackUserID: "myID", ackAt: 0)] : []
                    return hry
                }
            return .just(hoorays)
        }
        
        // when
        self.usecase.loadNearbyRecentHoorays("myID", at: .init(latt: 0, long: 0))
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}


extension HoorayReceiveUsecaseTests {
    
    func testUsecase_receiveNewHooray() {
        // given
        let expect = expectation(description: "새로운 후레이 수신")
        expect.expectedFulfillmentCount = 3
        
        
        // when
        let newHoorays = self.waitElements(expect, for: self.usecase.newReceivedHooray) {
            let newMessage: [NewHoorayMessage] = (0..<3).map{ .dummy($0) }
            newMessage.forEach {
                self.stubMessagingService.stubNewMessage.onNext($0)
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
        
        self.stubMessagingService.called(key: "sendMessage") { arg in
            guard let _ = arg as? HoorayAckMessage else { return }
            expect.fulfill()
        }
        
        self.usecase.newReceivedHooray
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // when
        let newMessage: [NewHoorayMessage] = (0..<3).map{ .dummy($0) }
        newMessage.forEach {
            self.stubMessagingService.stubNewMessage.onNext($0)
        }
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}
