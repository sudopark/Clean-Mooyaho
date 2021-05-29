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
    
    func updateUserIsOnline(_ userID: String, isOnline: Bool)
    
    func loadCurrentMembership() -> Maybe<MemberShip>
    
    var currentMember: Observable<Member?> { get }
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
}


extension MemberUsecaseImple {
    
    private func fetchCurrentMember() -> Member? {
        return self.sharedDataStoreService.fetch(.currentMember)
    }
    
    public func updateUserIsOnline(_ userID: String, isOnline: Bool) {
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
        
        guard let curent = self.fetchCurrentMember() else { return .error(ApplicationErrors.sigInNeed) }
        return self.memberRepository.requestLoadMembership(for: curent.uid)
    }
}


extension MemberUsecaseImple {
    
    public var currentMember: Observable<Member?> {
        return self.sharedDataStoreService
            .observe(SharedDataKeys.currentMember.rawValue)
    }
}
