//
//  ReadRemindMessagingService.swift
//  Domain
//
//  Created by sudo.park on 2021/10/18.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol ReadRemindMessagingService: MessagingService {
    
    func sendPendingMessage(_ message: ReadRemindMessage) -> Maybe<Void>
    
    func cancelMessage(for readMinderID: String) -> Maybe<Void>

    func boardcastRemind(_ message: ReadRemindMessage) -> Maybe<Void>
}
