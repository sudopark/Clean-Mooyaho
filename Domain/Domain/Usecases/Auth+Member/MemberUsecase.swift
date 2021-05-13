//
//  MemberUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/05/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


// MARK: - MemberUsecase

public protocol MemberUsecase { }


// MARK: - MemberUsecaseImple

public final class MemberUsecaseImple: MemberUsecase {
    
    
}


extension MemberUsecaseImple {
    
    public func updateUserIsOnline(_ userID: Int, isOnline: Bool) -> Maybe<Void> {
        return .empty()
    }
    
    
    public func loadNearbyUserLocations(at location: Coordinate) -> Maybe<[UserPresence]> {
        return .empty()
    }
}
