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
    
    public init(memberUsecase: MemberUsecase, hoorayRepository: HoorayRepository) {
        self.memberUsecase = memberUsecase
        self.hoorayRepository = hoorayRepository
    }
}


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


extension HoorayPublishUsecaseImple {
    
    var receiveHoorayReaction: Observable<HoorayReaction> {
        // TODO: Hooray 반응 모델링 및 구현 필요
        return .empty()
    }
}
