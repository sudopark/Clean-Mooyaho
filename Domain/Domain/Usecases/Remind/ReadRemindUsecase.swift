//
//  ReadRemindUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/10/19.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


// MARK: - ReadRemindUsecase

public protocol ReadRemindUsecase: ReadRemindUpdateUsecase, ReadRemindHandlingUsecase { }


// MARK: - ReadRemindUsecaseImple

public final class ReadRemindUsecaseImple: ReadRemindUsecase {
    
    private let authInfoProvider: AuthInfoProvider
    private let sharedDataStore: SharedDataStoreService
    private let reminderRepository: ReadRemindRepository
    private let messagingService: ReadRemindMessagingService
    
    public init(authInfoProvider: AuthInfoProvider,
                sharedDataStore: SharedDataStoreService,
                reminderRepository: ReadRemindRepository,
                messagingService: ReadRemindMessagingService) {
        
        self.authInfoProvider = authInfoProvider
        self.sharedDataStore = sharedDataStore
        self.reminderRepository = reminderRepository
        self.messagingService = messagingService
    }
}


extension ReadRemindUsecaseImple {
    
    public func scheduleRemind(for itemID: String, at futureTime: TimeStamp) -> Maybe<ReadRemind> {
        return .empty()
    }
    
    public func cancelRemin(for uid: String) -> Maybe<Void> {
        return .empty()
    }
}


extension ReadRemindUsecaseImple {
    
    public func readRemind(for itemID: String) -> Observable<ReadRemind> {
        return .empty()
    }
    
    public func handleReminder(_ readReminder: ReadRemind) -> Maybe<Void> {
        return .empty()
    }
}
