//
//  MockMessagingService.swift
//  DomainTests
//
//  Created by sudo.park on 2021/05/15.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import UnitTestHelpKit

@testable import Domain


class MockMessagingService: MessagingService, Mocking {
    
    
    let newMessage = PublishSubject<Message>()
    var receivedMessage: Observable<Message> {
        return self.newMessage.asObservable()
    }
}
