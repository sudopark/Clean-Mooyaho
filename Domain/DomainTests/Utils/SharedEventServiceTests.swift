//
//  SharedEventServiceTests.swift
//  DomainTests
//
//  Created by sudo.park on 2021/12/21.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit
import UsecaseDoubles


class SharedEventServiceTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
    }
    
    private func makeService() -> SharedEventService {
        return SharedEventServiceImple()
    }
}


extension SharedEventServiceTests {
    
    func testService_notifyEvent() {
        // given
        let expect = expectation(description: "공유되는 이벤트 전달")
        expect.expectedFulfillmentCount = 2
        let service = self.makeService()
        
        // when
        let notifiedEvents = self.waitElements(expect, for: service.event) {
            service.notify(event: UserSignInStatusChangeEvent.signIn(.init(userID: "some")))
            service.notify(event: UserSignInStatusChangeEvent.signOut(.init(userID: "some")))
        }
        
        // then
        XCTAssertEqual(notifiedEvents.count, 2)
        if case .signIn = notifiedEvents.first as? UserSignInStatusChangeEvent {
            XCTAssert(true)
        } else {
            XCTFail("signIn 이벤트가 아님")
        }
        if case .signOut = notifiedEvents.last as? UserSignInStatusChangeEvent {
            XCTAssert(true)
        } else {
            XCTFail("signOut 이벤트가 아님")
        }
    }
}
