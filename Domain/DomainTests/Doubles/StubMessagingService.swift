//
//  StubMessagingService.swift
//  DomainTests
//
//  Created by sudo.park on 2021/05/15.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import UnitTestHelpKit

@testable import Domain


class StubMessagingService: MessagingService, Mocking {
    
    var mockPermission: Bool?
    func prepareNotificationPermission() -> Maybe<Bool> {
        return mockPermission.map { .just($0) } ?? .just(true)
    }
    
    let newMessageMocking = PublishSubject<Message>()
    var receivedMessage: Observable<Message> {
        return self.newMessageMocking.asObservable()
    }
}


class StubReminderMessagingService: StubMessagingService, ReadRemindMessagingService {
    
    var didSentPendingMessage: ReadRemindMessage?
    var didCancelRemindID: String?
    
    var sendPendingMessageMocking: Void?
    func sendPendingMessage(_ message: ReadRemindMessage) -> Maybe<Void> {
        self.didSentPendingMessage = message
        return self.sendPendingMessageMocking.map { .just($0) } ?? .just()
    }
    
    func cancelMessage(for readMinderID: String) -> Maybe<Void> {
        self.didCancelRemindID = readMinderID
        return .just()
    }
    
    var broadcastResultMocking: Void?
    var didBroadcastedMessage: ReadRemindMessage?
    func broadcastRemind(_ message: ReadRemindMessage) -> Maybe<Void> {
        self.didBroadcastedMessage = message
        return self.broadcastResultMocking.map { .just($0) } ?? .just()
    }
}
