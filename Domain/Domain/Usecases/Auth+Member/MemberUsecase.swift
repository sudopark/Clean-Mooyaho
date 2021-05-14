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
    
    private let disposeBag: DisposeBag = .init()
    private let memberRepository: MemberRepository
    
    public init(memberRepository: MemberRepository) {
        self.memberRepository = memberRepository
    }
}


extension MemberUsecaseImple {
    
    public func updateUserIsOnline(_ userID: Int, isOnline: Bool) {
        self.memberRepository.requestUpdateUserPresence(userID, isOnline: isOnline)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
    
    
    public func loadNearbyUsers(at location: Coordinate) -> Maybe<[UserPresence]> {
        return self.memberRepository
            .requestLoadNearbyUsers(at: location)
    }
}
