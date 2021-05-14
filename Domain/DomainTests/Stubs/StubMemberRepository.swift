//
//  StubMemberRepository.swift
//  DomainTests
//
//  Created by sudo.park on 2021/05/15.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import UnitTestHelpKit

@testable import Domain


class StubMemberRepository: MemberRepository, Stubbable {
    
    func requestUpdateUserPresence(_ userID: Int, isOnline: Bool) -> Maybe<Void> {
        self.verify(key: "requestUpdateUserPresence", with: isOnline)
        return self.resolve(key: "requestUpdateUserPresence") ?? .empty()
    }
    
    func requestLoadNearbyUsers(at location: Coordinate) -> Maybe<[UserPresence]> {
        return self.resolve(key: "requestLoadNearbyUsers") ?? .empty()
    }
}
