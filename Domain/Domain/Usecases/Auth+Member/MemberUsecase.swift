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

public protocol MemberUsecase {
    
    func loadCurrentMembership() -> Maybe<MemberShip>
}


// MARK: - MemberUsecaseImple

public final class MemberUsecaseImple: MemberUsecase {
    
    private let disposeBag: DisposeBag = .init()
    private let memberRepository: MemberRepository
    private let sharedDataStoreService: SharedDataStoreService
    
    public init(memberRepository: MemberRepository,
                sharedDataService: SharedDataStoreService) {
        
        self.memberRepository = memberRepository
        self.sharedDataStoreService = sharedDataService
    }
    
    private var currentMember: Member? {
        return self.sharedDataStoreService.fetch(.currentMember)
    }
}


extension MemberUsecaseImple {
    
    public func updateUserIsOnline(_ userID: Int, isOnline: Bool) {
        self.memberRepository.requestUpdateUserPresence(userID, isOnline: isOnline)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
    
    
//    public func loadNearbyUsers(at location: Coordinate) -> Maybe<[UserPresence]> {
//        return self.memberRepository
//            .requestLoadNearbyUsers(at: location)
//    }
    
    public func loadCurrentMembership() -> Maybe<MemberShip> {
        
        if let existing: MemberShip = self.sharedDataStoreService.fetch(.membership) {
            return .just(existing)
        }
        
        guard let curent = self.currentMember else { return .error(ApplicationErrors.noAuth) }
        return self.memberRepository.requestLoadMembership(for: curent.uid)
    }
}
