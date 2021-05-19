//
//  MemberRepository.swift
//  Domain
//
//  Created by sudo.park on 2021/05/15.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol UserRepository {
    
    func requestUpdateUserPresence(_ userID: Int, isOnline: Bool) -> Maybe<Void>
    
//    func requestLoadNearbyUsers(at location: Coordinate) -> Maybe<[UserPresence]>
}

public protocol MemberRepository: UserRepository {
    
    func requestLoadMembership(for memberID: String) -> Maybe<MemberShip>
}
