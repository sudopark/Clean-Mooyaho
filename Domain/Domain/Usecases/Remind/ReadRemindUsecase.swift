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
    
    func updateRemind(for item: ReadItem, futureTime: TimeStamp?) -> Maybe<Void>
    
    func handleReminder(_ readReminder: ReadRemindMessage) -> Maybe<Void>
}

extension ReadRemindUsecase {
    
    public func scheduleRemid(for item: ReadItem, futureTime: TimeStamp) -> Maybe<Void> {
        return self.updateRemind(for: item, futureTime: futureTime)
    }
    
    public func cancelRemind(for item: ReadItem) -> Maybe<Void> {
        return self.updateRemind(for: item, futureTime: nil)
    }
}


// MARK: - ReadRemindUsecaseImple

public final class ReadRemindUsecaseImple: ReadRemindUsecase {
    
    private let authInfoProvider: AuthInfoProvider
    private let sharedStore: SharedDataStoreService
    private let readItemUsecase: ReadItemUsecase
    private let messagingService: ReadRemindMessagingService
    
    public init(authInfoProvider: AuthInfoProvider,
                sharedStore: SharedDataStoreService,
                readItemUsecase: ReadItemUsecase,
                messagingService: ReadRemindMessagingService) {
        
        self.authInfoProvider = authInfoProvider
        self.sharedStore = sharedStore
        self.readItemUsecase = readItemUsecase
        self.messagingService = messagingService
    }
    
    private let disposeBag = DisposeBag()
}


extension ReadRemindUsecaseImple {
    
    public func preparePermission() -> Maybe<Bool> {
        return self.messagingService.prepareNotificationPermission()
    }
    
    public func updateRemind(for item: ReadItem, futureTime: TimeStamp?) -> Maybe<Void> {
        
        return futureTime
            .map { self.doScheduleRemind(for: item, at: $0) }
            ?? self.doCancelRemind(item)
    }
    
    private func doScheduleRemind(for item: ReadItem, at futureTime: TimeStamp) -> Maybe<Void> {

        let updateRemind = self.updateItem(item, remindTime: futureTime)
        
        let thenPrepareReadRemindMessage: () -> ReadRemindMessage?
        thenPrepareReadRemindMessage = { [weak self] in
            return self?.prepareReadRemindMessage(for: item, time: futureTime)
        }
        
        let sendPendingMessage: (ReadRemindMessage) -> Maybe<Void> = { [weak self] message in
            return self?.messagingService.sendPendingMessage(message) ?? .empty()
        }
        
        return updateRemind
            .compactMap(thenPrepareReadRemindMessage)
            .flatMap(sendPendingMessage)
    }
    
    private func doCancelRemind(_ item: ReadItem) -> Maybe<Void> {
        
        let cancelPendingMessage: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.disposeBag.insert <| self.messagingService.cancelMessage(for: item.uid).subscribe()
        }
        
        return self.updateItem(item, remindTime: nil)
            .do(onNext: cancelPendingMessage)
    }
    
    private func updateItem(_ item: ReadItem, remindTime: TimeStamp?) -> Maybe<Void> {
        let params = ReadItemUpdateParams(itemID: item.uid, isCollection: item is ReadCollection)
            |> \.updatePropertyParams .~ [.remindTime(remindTime)]
        return self.readItemUsecase.updateItem(params)
    }
    
    private func prepareReadRemindMessage(for item: ReadItem,
                                          time: TimeStamp) -> ReadRemindMessage? {
        
        switch item {
        case let collection as ReadCollection:
            return ReadRemindMessage(itemID: item.uid, scheduledTime: time)
                |> \.message .~ pure("It's time to start read '%@' read collection".localized(with: collection.name))
            
        case let link as ReadLink:
            return ReadRemindMessage(itemID: item.uid, scheduledTime: time)
                |> \.message .~ pure("\(ReadRemindMessage.defaultReadLinkMessage)(\(link.link))")
                
        default: return nil
        }
    }
}


extension ReadRemindUsecaseImple {
    
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
