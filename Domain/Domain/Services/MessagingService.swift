//
//  MessagingService.swift
//  Domain
//
//  Created by sudo.park on 2021/05/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


// MARK: - MessagingService

public protocol MessagingService {
    
    func prepareNotificationPermission() -> Maybe<Bool>
    
    var receivedMessage: Observable<Message> { get }
}
