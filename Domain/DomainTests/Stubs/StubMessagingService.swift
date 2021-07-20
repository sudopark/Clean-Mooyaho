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


class StubMessagingService: MessagingService, Stubbable {
    
    
    let stubNewMessage = PublishSubject<Messsage>()
    var receivedMessage: Observable<Messsage> {
        return self.stubNewMessage.asObservable()
    }
}
