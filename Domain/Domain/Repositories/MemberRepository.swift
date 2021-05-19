//
//  MemberRepository.swift
//  Domain
//
//  Created by sudo.park on 2021/05/15.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol MemberRepository {
    
    func requestUpdateUserPresence(_ userID: String, isOnline: Bool) -> Maybe<Void>
    
    func requestLoadMembership(for memberID: String) -> Maybe<MemberShip>
}
