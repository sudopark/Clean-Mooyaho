//
//  HoorayReceiveUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/05/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


// MARK: - HoorayReceiverUsecase

public protocol HoorayReceiverUsecase { }


// MARK: - HoorayReceiverUsecaseImple

public final class HoorayReceiverUsecaseImple: HoorayReceiverUsecase {
    
    private let messageService: MessagingService
    
    public init(messageService: MessagingService) {
        self.messageService = messageService
    }
}


extension HoorayReceiverUsecaseImple {
    
    enum AliveHoorayDetectionPolicy {
        
        static let validDistance: Meters = 0
        static let alivableTimeInterval: TimeInterval = 0
    }
    
    public func loadNearbyRecentHoorays(at location: Coordinate) -> Maybe<[Hooray]> {
        // TODO: 근처에 유효한 후레이 조회 + ack 처리
        return .empty()
    }
    
    public func ackReceivedHooray(_ hoorayID: String) -> Maybe<Void> {
        // TODO: 후레이 수신확인 -> 메세지는 아래단에서 보냄
        return .empty()
    }
}

extension HoorayReceiverUsecaseImple {
    
    public var newReceivedHooray: Observable<Hooray> {
        // TODO: 실시간 받은 무야호 필터링해서 전파
        .empty()
    }
}
