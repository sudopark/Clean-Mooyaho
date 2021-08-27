//
//  BaseStubHoorayRepository.swift
//  DomainTests
//
//  Created by sudo.park on 2021/08/26.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


class BaseStubHoorayRepository: HoorayRepository {
    
    func fetchLatestHooray(_ memberID: String) -> Maybe<LatestHooray?> {
        return .empty()
    }
    
    func requestLoadLatestHooray(_ memberID: String) -> Maybe<LatestHooray?> {
        return .empty()
    }
    
    func requestPublishHooray(_ newForm: NewHoorayForm, withNewPlace: NewPlaceForm?) -> Maybe<Hooray> {
        return .empty()
    }
    
    func requestLoadNearbyRecentHoorays(at location: Coordinate) -> Maybe<[Hooray]> {
        return .empty()
    }
    
    func requestAckHooray(_ ack: HoorayAckMessage) -> Maybe<Void> {
        return .empty()
    }
    
    func requestLoadHooray(_ id: String) -> Maybe<Hooray> {
        return .empty()
    }
    
    func fetchHooray(_ id: String) -> Maybe<Hooray?> {
        return .empty()
    }
}
