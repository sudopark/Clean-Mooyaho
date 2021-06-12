//
//  FCMService.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/05/29.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain

class FCMService: MessagingService {
    
    func sendMessages(_ messages: [Messsage]) -> Maybe<Void> {
        return .just()
    }
    
    var receivedMessage: Observable<Messsage> {
        return .empty()
    }
}
