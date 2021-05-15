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
    
    func sendMessage(_ message: Messsage) -> Maybe<Void>
    
    var receivedMessage: Observable<Messsage> { get }
}