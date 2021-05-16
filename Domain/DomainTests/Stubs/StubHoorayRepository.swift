//
//  StubHoorayRepository.swift
//  DomainTests
//
//  Created by sudo.park on 2021/05/15.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import UnitTestHelpKit

@testable import Domain

class StubHoorayRepository: HoorayRepository, Stubbable {
    
    func fetchLatestHooray(_ memberID: String) -> Maybe<LatestHooray?> {
        return self.resolve(key: "fetchLatestHooray") ?? .empty()
    }
    
    func requestLoadLatestHooray(_ memberID: String) -> Maybe<LatestHooray?> {
        return self.resolve(key: "requestLoadLatestHooray") ?? .empty()
    }
    
    func requestPublishHooray(_ newForm: NewHoorayForm, withNewPlace: NewPlaceForm?) -> Maybe<Hooray> {
        return self.resolve(key: "requestPublishHooray") ?? .empty()
    }
    
    func requestLoadNearbyRecentHoorays(at location: Coordinate) -> Maybe<[Hooray]> {
        return self.resolve(key: "requestLoadNearbyRecentHoorays") ?? .empty()
    }
}
