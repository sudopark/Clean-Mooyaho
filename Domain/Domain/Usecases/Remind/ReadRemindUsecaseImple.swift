//
//  ReadRemindUsecaseImple.swift
//  Domain
//
//  Created by sudo.park on 2021/11/11.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import Prelude
import Optics


// MARK: - ReadRemindUsecaseImple

public final class ReadRemindUsecaseImple: ReadRemindUsecase, RemindOptionUsecase {
    
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


// MARK: - ReadRemindUsecaseImple + Remind

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
        let params = ReadItemUpdateParams(item: item)
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


// MARK: - setting

extension ReadRemindUsecaseImple {
    
    public func loadDefaultRemindTime() -> Maybe<RemindTime> {
        return .empty()
    }
    
    public func updateDefaultRemindTime(_ time: RemindTime) -> Maybe<Void> {
        return .empty()
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
