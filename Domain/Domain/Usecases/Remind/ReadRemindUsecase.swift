//
//  ReadRemindUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/10/19.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import Prelude
import Optics


// MARK: - ReadRemindUsecase

public protocol ReadRemindUsecase {
    
    func preparePermission() -> Maybe<Bool>
    
    func scheduleRemind(for itemID: ReadItem, at futureTime: TimeStamp) -> Maybe<ReadRemind>
    
    func cancelRemind(_ remind: ReadRemind) -> Maybe<Void>
    
    func readReminds(for itemIDs: [String]) -> Observable<[ReadRemind]>
    
    func handleReminder(_ readReminder: ReadRemindMessage) -> Maybe<Void>
}


// MARK: - ReadRemindUsecaseImple

public final class ReadRemindUsecaseImple: ReadRemindUsecase {
    
    private let authInfoProvider: AuthInfoProvider
    private let sharedStore: SharedDataStoreService
    private let readItemUsecase: ReadItemUsecase
    private let reminderRepository: ReadRemindRepository
    private let messagingService: ReadRemindMessagingService
    
    public init(authInfoProvider: AuthInfoProvider,
                sharedStore: SharedDataStoreService,
                readItemUsecase: ReadItemUsecase,
                reminderRepository: ReadRemindRepository,
                messagingService: ReadRemindMessagingService) {
        
        self.authInfoProvider = authInfoProvider
        self.sharedStore = sharedStore
        self.readItemUsecase = readItemUsecase
        self.reminderRepository = reminderRepository
        self.messagingService = messagingService
    }
    
    private let disposeBag = DisposeBag()
}


extension ReadRemindUsecaseImple {
    
    public func preparePermission() -> Maybe<Bool> {
        return self.messagingService.prepareNotificationPermission()
    }
    
    public func scheduleRemind(for item: ReadItem, at futureTime: TimeStamp) -> Maybe<ReadRemind> {

        let remind = ReadRemind(itemID: item.uid, scheduledTime: futureTime)
                
        let updateRemind = self.reminderRepository.requestScheduleReadRemind(remind)
        
        let thenPrepareReadRemindMessage: () -> ReadRemindMessage?
        thenPrepareReadRemindMessage = { [weak self] in
            return self?.prepareReadRemindMessage(for: item, remind: remind)
        }
        
        let sendPendingMessage: (ReadRemindMessage) -> Maybe<Void> = { [weak self] message in
            return self?.messagingService.sendPendingMessage(message) ?? .empty()
        }
        
        return updateRemind
            .compactMap(thenPrepareReadRemindMessage)
            .flatMap(sendPendingMessage)
            .map { remind }
    }
    
    public func cancelRemind(_ remind: ReadRemind) -> Maybe<Void> {
        
        let cancelPendingMessage: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.disposeBag.insert <| self.messagingService.cancelMessage(for: remind.uid).subscribe()
        }
        
        let removeAtSharedStore: () -> Void = { [weak self] in
            guard let self = self else { return }
            let datKey = SharedDataKeys.readMindersMap
            self.sharedStore.update([String: ReadRemind].self, key: datKey.rawValue) {
                ($0 ?? [:]) |> key(remind.itemID) .~ nil
            }
        }
        
        return self.reminderRepository.requestCancelReadRemind(for: remind.uid)
            .do(onNext: cancelPendingMessage)
            .do(onNext: removeAtSharedStore)
    }
    
    private func prepareReadRemindMessage(for item: ReadItem,
                                          remind: ReadRemind) -> ReadRemindMessage? {
        
        switch item {
        case let collection as ReadCollection:
            return ReadRemindMessage(itemID: item.uid)
                |> \.message .~ pure("It's time to start read '%@' read collection".localized(with: collection.name))
            
        case let link as ReadLink:
            return ReadRemindMessage(itemID: item.uid)
                |> \.message .~ pure("\(ReadRemindMessage.defaultReadLinkMessage)(\(link.link))")
                
        default: return nil
        }
    }
}


extension ReadRemindUsecaseImple {
    
    public func readReminds(for itemIDs: [String]) -> Observable<[ReadRemind]> {
        
        let refreshRemminds: () -> Void = { [weak self] in
            self?.refreshReminds(for: itemIDs)
        }
        
        let filterMatchingReminds: ([String: ReadRemind]?) -> [ReadRemind] = { dict in
            return itemIDs.compactMap { dict?[$0] }
        }
        
        let datKey = SharedDataKeys.readMindersMap
        return self.sharedStore
            .observeWithCache([String: ReadRemind].self, key: datKey.rawValue)
            .map(filterMatchingReminds)
            .do(onSubscribed: refreshRemminds)
    }
    
    private func refreshReminds(for itemIDs: [String]) {
        
        let updateStore: ([ReadRemind]) -> Void = { [weak self] reminds in
            guard let self = self else { return }
            let datKey = SharedDataKeys.readMindersMap
            self.sharedStore.update([String: ReadRemind].self, key: datKey.rawValue) {
                reminds.reduce(($0 ?? [:])) { $0 |> key($1.itemID) .~ $1 }
            }
        }
        
        self.reminderRepository.requestLoadReadReminds(for: itemIDs)
            .subscribe(onNext: updateStore)
            .disposed(by: self.disposeBag)
    }
    
    public func handleReminder(_ readReminder: ReadRemindMessage) -> Maybe<Void> {
        return self.messagingService.broadcastRemind(readReminder)
    }
}


private extension LinkPreview {
    
    static var empty: LinkPreview {
        return .init(title: nil, description: nil, mainImageURL: nil, iconURL: nil)
    }
    
    var isEmptyTitle: Bool {
        return self.title?.isNotEmpty != false
    }
}
