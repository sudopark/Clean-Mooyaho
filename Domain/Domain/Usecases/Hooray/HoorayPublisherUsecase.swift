//
//  HoorayPublisherUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/05/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import Overture


// MARK: - Hooray PublishPolicy

public enum HoorayPublishPolicy {
    
    public static let defaultCooltime: Seconds  = 10 * 60
    public static let defaultSpreadDistance: Meters = 1_000
}

// MARK: - HoorayPublisherUsecase

public protocol HoorayPublisherUsecase {
    
    func isAvailToPublish() -> Maybe<Void>
    
    func publish(newHooray hoorayForm: NewHoorayForm,
                 withNewPlace placeForm: NewPlaceForm?) -> Maybe<Hooray>
    
    var newHoorayPublished: Observable<Hooray> { get }
    
    var receiveHoorayAck: Observable<HoorayAckMessage> { get }
    
    var receiveHoorayReaction: Observable<HoorayReactionMessage> { get }
}

// MARK: - HoorayPubisherDefaultImpleDependency

public protocol HoorayPubisherUsecaseDefaultImpleDependency: AnyObject {
    
    var memberUsecase: MemberUsecase { get }
    var hoorayRepository: HoorayRepository { get }
    var messagingService: MessagingService { get }
    var publishedHooray: PublishSubject<Hooray> { get }
}


// MARK: HoorayPubisher default implementation -> publish hoorays

extension HoorayPublisherUsecase where Self: HoorayPubisherUsecaseDefaultImpleDependency {
    
    private func checkAndLoadMemberShipWhenAvailToPublish() -> Maybe<MemberShip> {
        func checkShouldWaitUntil(_ latest: LatestHooray?, with memberShip: MemberShip) -> TimeStamp? {
            guard let latest = latest else { return nil }
            // TODO: 멤버쉽에 따라 쿨타임 조정
            let coolTime = HoorayPublishPolicy.defaultCooltime
            let waitNeedUntil = latest.time + coolTime.asTimeInterval()
            return waitNeedUntil > TimeStamp.now() ? waitNeedUntil : nil
        }
        
        guard let member = self.memberUsecase.fetchCurrentMember() else {
            return .error(ApplicationErrors.sigInNeed)
        }
        guard member.isProfileSetup else {
            return .error(ApplicationErrors.profileNotSetup)
        }
    
        let loadMemberShipAndLocalLatestHooray = Maybe
            .zip(self.memberUsecase.loadCurrentMembership(),
                 self.hoorayRepository.fetchLatestHooray(member.uid))
        
        let throwWhenTooSoonHoorayExistsOnLocal: (MemberShip, LatestHooray?) throws -> MemberShip
        throwWhenTooSoonHoorayExistsOnLocal = { memberShip, latest in
            guard let shouldwaitUntil = checkShouldWaitUntil(latest, with: memberShip) else {
                return memberShip
            }
            throw ApplicationErrors.shouldWaitPublishHooray(until: shouldwaitUntil)
        }
        let thenLoadRecentHoorayFromRemoteAndCheck: (MemberShip) -> Maybe<MemberShip>
        thenLoadRecentHoorayFromRemoteAndCheck = { [weak self] memberShip in
            guard let self = self else { return .empty() }
            return self.hoorayRepository.requestLoadLatestHooray(member.uid)
                .map { latest in
                    guard let shouldwaitUntil = checkShouldWaitUntil(latest, with: memberShip) else {
                        return memberShip
                    }
                    throw ApplicationErrors.shouldWaitPublishHooray(until: shouldwaitUntil)
                }
        }
        
        return loadMemberShipAndLocalLatestHooray
            .map(throwWhenTooSoonHoorayExistsOnLocal)
            .flatMap(thenLoadRecentHoorayFromRemoteAndCheck)
    }

    public func isAvailToPublish() -> Maybe<Void> {
        return self.checkAndLoadMemberShipWhenAvailToPublish()
            .map{ _ in }
    }
    
    public func publish(newHooray hoorayForm: NewHoorayForm,
                        withNewPlace placeForm: NewPlaceForm?) -> Maybe<Hooray> {
        
        let checkAndLoadMemberShip = self.checkAndLoadMemberShipWhenAvailToPublish()
        let applyPolicy: (MemberShip) -> NewHoorayForm = { memberShip in
            return update(hoorayForm) {
                $0.spreadDistance = memberShip.hooraySpreadDistance()
                $0.aliveTime = memberShip.hoorayAliveTime()
                $0.timeStamp = .now()
            }
        }
        let thenPublish: (NewHoorayForm) -> Maybe<Hooray> = { [weak self] form in
            guard let self = self else { return .empty() }
            return self.hoorayRepository.requestPublishHooray(form, withNewPlace: placeForm)
        }
        
        let emitPublishedEvent: (Hooray) -> Void = { [weak self] hooray in
            self?.publishedHooray.onNext(hooray)
        }
        
        return checkAndLoadMemberShip
            .map(applyPolicy)
            .flatMap(thenPublish)
            .do(onNext: emitPublishedEvent)
    }
}


// MARK: HoorayPubisher default implementation -> handle hooray responses

extension HoorayPublisherUsecase where Self: HoorayPubisherUsecaseDefaultImpleDependency {
    
    public var newHoorayPublished: Observable<Hooray> {
        return self.publishedHooray.asObservable()
    }
    
    public var receiveHoorayAck: Observable<HoorayAckMessage> {
        return self.messagingService.receivedMessage
            .compactMap{ $0 as? HoorayAckMessage }
    }
    
    public var receiveHoorayReaction: Observable<HoorayReactionMessage> {
        return self.messagingService.receivedMessage
            .compactMap{ $0 as? HoorayReactionMessage }
    }
}


private extension MemberShip {
    
    func hoorayAliveTime() -> TimeInterval {
        return Policy.hoorayAliveTime
    }
    
    func hooraySpreadDistance() -> Meters {
        return Policy.hoorayDefaultSpreadDistance
    }
}
