//
//  HoorayUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/05/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

// MARK: - HoorayUsecase

public protocol HoorayUsecase: HoorayPublisherUsecase, HoorayReceiverUsecase { }


// MARK: - HoorayUsecaseImple

public final class HoorayUsecaseImple: HoorayUsecase,
                                       HoorayPubisherUsecaseDefaultImpleDependency,
                                       HoorayReceiveUsecaseDefaultImpleDependency {
    
    public let authInfoProvider: AuthInfoProvider
    public let memberUsecase: MemberUsecase
    public let hoorayRepository: HoorayRepository
    public let messagingService: MessagingService
    public let sharedStoreService: SharedDataStoreService
    
    public init(authInfoProvider: AuthInfoProvider, memberUsecase: MemberUsecase,
                hoorayRepository: HoorayRepository,
                messagingService: MessagingService, sharedStoreService: SharedDataStoreService) {
        self.authInfoProvider = authInfoProvider
        self.memberUsecase = memberUsecase
        self.hoorayRepository = hoorayRepository
        self.messagingService = messagingService
        self.sharedStoreService = sharedStoreService
    }
    
    public let disposeBag: DisposeBag = DisposeBag()
}
