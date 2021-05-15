//
//  HoorayPublisherUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/05/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


// MARK: - Hooray PublishPolicy

public enum HoorayPublishPolicy {
    
    public static let defaultCooltime: Seconds  = 10 * 60
}

// MARK: - HoorayPublisherUsecase

public protocol HoorayPublisherUsecase { }


// MARK: - HoorayPublishUsecaseImple

public final class HoorayPublishUsecaseImple {
    
    private let memberUsecase: MemberUsecase
    private let hoorayRepository: HoorayRepository
    private let messagingService: MessagingService
    
    public init(memberUsecase: MemberUsecase,
                hoorayRepository: HoorayRepository,
                messagingService: MessagingService) {
        self.memberUsecase = memberUsecase
        self.hoorayRepository = hoorayRepository
        self.messagingService = messagingService
    }
}


// MARK: - publish hoorays

extension HoorayPublishUsecaseImple {
    
    public func isAvailToPublish(_ memberID: String) -> Maybe<Bool> {
        
        let loadRequireInfos = Maybe
            .zip(self.hoorayRepository.requestLoadLatestHooray(memberID),
                 self.memberUsecase.loadCurrentMembership())
        
        let thenCheckPublishable: (LatestHooray?, MemberShip) -> Bool = { latest, _ in
            guard let latest = latest else { return true }
            // TODO: 멤버쉽에 따라 쿨타임 조정
            let interval = abs(TimeSeconds.now() - latest.time)
            let isAvail = HoorayPublishPolicy.defaultCooltime.asTimeInterval() <= interval
            return isAvail
        }
        
        return loadRequireInfos
            .map(thenCheckPublishable)
    }
    
    public func publish(newHooray hoorayForm: NewHoorayForm,
                        withNewPlace placeForm: NewPlaceForm?) -> Maybe<Hooray> {
         
        return self.hoorayRepository.requestPublishHooray(hoorayForm, withNewPlace: placeForm)
    }
}


// MARK: - handle hooray responses

extension HoorayPublishUsecaseImple {
    
    var receiveHoorayAck: Observable<HoorayAck> {
        return self.messagingService.receivedMessage
            .compactMap{ $0 as? HoorayAckMessage }
            .map{ $0.asAck() }
    }
    
    var receiveHoorayReaction: Observable<HoorayReaction> {
        return self.messagingService.receivedMessage
            .compactMap{ $0 as? HoorayReactionMessage }
            .map{ $0.asReaction() }
    }
}


private extension HoorayAckMessage {
    
    func asAck() -> HoorayAck {
        return (self.hoorayID, self.ackUserID)
    }
}


private extension HoorayReactionMessage {
    
    func asReaction() -> HoorayReaction {
        return .init(hoorayID: self.hoorayID, reactionInfo: self.reactionInfo)
    }
}
