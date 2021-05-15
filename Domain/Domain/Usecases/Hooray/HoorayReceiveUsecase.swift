//
//  HoorayReceiveUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/05/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


// MARK: - HoorayReceiverUsecase

public protocol HoorayReceiverUsecase { }


// MARK: - HoorayReceiverUsecaseImple

public final class HoorayReceiverUsecaseImple: HoorayReceiverUsecase {
    
    private let authInfoProvider: AuthInfoProvider
    private let hoorayRepository: HoorayRepository
    private let messageService: MessagingService
    
    public init(authInfoProvider: AuthInfoProvider,
                hoorayRepository: HoorayRepository,
                messageService: MessagingService) {
        
        self.authInfoProvider = authInfoProvider
        self.hoorayRepository = hoorayRepository
        self.messageService = messageService
    }
    
    private let disposeBag = DisposeBag()
}


extension HoorayReceiverUsecaseImple {
    
    public func loadNearbyRecentHoorays(_ userID: String,
                                        at location: Coordinate) -> Maybe<[Hooray]> {
        let sendAcksIfNeed: ([Hooray]) -> Void = { [weak self] hoorays in
            let ackMessages: [HoorayAckMessage] = hoorays
                .filter{ $0.ackUserIDs.contains(userID) == false }
                .map{ .init(hoorayID: $0.uid, publisherID: $0.publisherID, ackUserID: userID) }
            self?.ackReceivedHooray(ackMessages: ackMessages)
        }
        
        return self.hoorayRepository.requestLoadNearbyRecentHoorays(at: location)
            .do(onNext: sendAcksIfNeed)
    }
    
    private func ackReceivedHooray(ackMessages: [HoorayAckMessage]) {
        let sendings = ackMessages.map{ self.messageService.sendMessage($0).subscribe() }
        self.disposeBag.insert(sendings)
    }
}

extension HoorayReceiverUsecaseImple {
    
    public var newReceivedHooray: Observable<NewHoorayMessage> {
        
        let sendAck: (NewHoorayMessage) -> Void = { [weak self] hoorayMessage in
            guard let self = self, let auth = self.authInfoProvider.currentAuth() else { return }
            let ackMessage = HoorayAckMessage(hoorayID: hoorayMessage.hoorayID,
                                              publisherID: hoorayMessage.publisherID,
                                              ackUserID: auth.userID)
            self.ackReceivedHooray(ackMessages: [ackMessage])
        }
        
        return self.messageService.receivedMessage
            .compactMap{ $0 as? NewHoorayMessage }
            .do(onNext: sendAck)
    }
}

private extension Set where Element == HoorayAckInfo {
    
    func contains(_ userID: String) -> Bool {
        let wildcardInfoForThisUser = HoorayAckInfo(ackUserID: userID, ackAt: 0)
        return self.contains(wildcardInfoForThisUser)
    }
}
