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

public protocol HoorayPubisherUsecaseDefaultImpleDependency: AnyObject {
    
    var memberUsecase: MemberUsecase { get }
    var hoorayRepository: HoorayRepository { get }
    var messagingService: MessagingService { get }
}


// MARK: HoorayPubisher default implementation -> publish hoorays

fileprivate struct TooSoonLatestHoorayExistInLocal: Error {}

extension HoorayPublisherUsecase where Self: HoorayPubisherUsecaseDefaultImpleDependency {

    public func isAvailToPublish(_ memberID: String) -> Maybe<Bool> {
        
        func checkIsEnoughTimePasses(_ latest: LatestHooray?, with memberShip: MemberShip) -> Bool {
            guard let latest = latest else { return true }
            // TODO: 멤버쉽에 따라 쿨타임 조정
            let interval = abs(TimeStamp.now() - latest.time)
            return HoorayPublishPolicy.defaultCooltime.asTimeInterval() <= interval
        }
    
        let loadMemberShipAndLocalLatestHooray = Maybe
            .zip(self.memberUsecase.loadCurrentMembership(),
                 self.hoorayRepository.fetchLatestHooray(memberID))
        
        let throwWhenTooSoonHoorayExistsOnLocal: (MemberShip, LatestHooray?) throws -> MemberShip
        throwWhenTooSoonHoorayExistsOnLocal = { memberShip, latest in
            guard checkIsEnoughTimePasses(latest, with: memberShip) == false else {
                return memberShip
            }
            throw TooSoonLatestHoorayExistInLocal()
        }
        let thenLoadRecentHoorayFromRemoteAndCheck: (MemberShip) -> Maybe<Bool>
        thenLoadRecentHoorayFromRemoteAndCheck = { [weak self] memberShip in
            guard let self = self else { return .empty() }
            return self.hoorayRepository.requestLoadLatestHooray(memberID)
                .map{ checkIsEnoughTimePasses($0, with: memberShip) }
        }
        let catchTooSoonLocalHoorayExistsError: (Error) -> Maybe<Bool> = { error in
            guard error is TooSoonLatestHoorayExistInLocal else {
                return .error(error)
            }
            return .just(false)
        }
        
        return loadMemberShipAndLocalLatestHooray
            .map(throwWhenTooSoonHoorayExistsOnLocal)
            .flatMap(thenLoadRecentHoorayFromRemoteAndCheck)
            .catch(catchTooSoonLocalHoorayExistsError)
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
