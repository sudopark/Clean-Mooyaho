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

public protocol HoorayPublisherUsecase {
    
    func isAvailToPublish(_ memberID: String) -> Maybe<Bool>
    
    func publish(newHooray hoorayForm: NewHoorayForm,
                        withNewPlace placeForm: NewPlaceForm?) -> Maybe<Hooray>
    
    var receiveHoorayAck: Observable<HoorayAckMessage> { get }
    
    var receiveHoorayReaction: Observable<HoorayReactionMessage> { get }
}

// MARK: - HoorayPubisherDefaultImpleDependency

public protocol HoorayPubisherUsecaseDefaultImpleDependency {
    
    var memberUsecase: MemberUsecase { get }
    var hoorayRepository: HoorayRepository { get }
    var messagingService: MessagingService { get }
}


// MARK: HoorayPubisher default implementation -> publish hoorays

extension HoorayPublisherUsecase where Self: HoorayPubisherUsecaseDefaultImpleDependency {
    
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


// MARK: HoorayPubisher default implementation -> handle hooray responses

extension HoorayPublisherUsecase where Self: HoorayPubisherUsecaseDefaultImpleDependency {
    
    public var receiveHoorayAck: Observable<HoorayAckMessage> {
        return self.messagingService.receivedMessage
            .compactMap{ $0 as? HoorayAckMessage }
    }
    
    public var receiveHoorayReaction: Observable<HoorayReactionMessage> {
        return self.messagingService.receivedMessage
            .compactMap{ $0 as? HoorayReactionMessage }
    }
}
