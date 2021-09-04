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

public protocol HoorayReceiverUsecase: AnyObject {
    
    func loadNearbyRecentHoorays(at location: Coordinate) -> Maybe<[Hooray]>
    
    func loadHooray(_ id: String) -> Maybe<Hooray>
    
    func loadHoorayHoorayDetail(_ id: String) -> Observable<HoorayDetail>
    
    var newReceivedHoorayMessage: Observable<NewHoorayMessage> { get }
}


// MARK: - HoorayReceiveUsecaseDefaultImpleDependency

public protocol HoorayReceiveUsecaseDefaultImpleDependency {
    
    var authInfoProvider: AuthInfoProvider { get }
    var hoorayRepository: HoorayRepository { get }
    var messagingService: MessagingService { get }
    var disposeBag: DisposeBag { get }
}


// MARK: - HoorayReceiverUsecase default implementations

extension HoorayReceiverUsecase where Self: HoorayReceiveUsecaseDefaultImpleDependency {
    
    public func loadNearbyRecentHoorays(at location: Coordinate) -> Maybe<[Hooray]> {
        
        
        let sendAcksIfNeed: ([Hooray]) -> Void = { [weak self] hoorays in
            guard let userID = self?.authInfoProvider.currentAuth()?.userID else { return }
            let targetHoorays: [Hooray] = hoorays
                .filter{ $0.publisherID != userID }
            let acks = targetHoorays
                .map { HoorayAckMessage(hoorayID: $0.uid, publisherID: $0.publisherID, ackUserID: userID) }
            self?.hoorayRepository.requestAckHooray(acks)
        }
        
        return self.hoorayRepository.requestLoadNearbyRecentHoorays(at: location)
            .do(onNext: sendAcksIfNeed)
    }
    
    public var newReceivedHoorayMessage: Observable<NewHoorayMessage> {
        
        let sendAck: (NewHoorayMessage) -> Void = { [weak self] hoorayMessage in
            guard let auth = self?.authInfoProvider.currentAuth() else { return }
            let ack = HoorayAckMessage(hoorayID: hoorayMessage.hoorayID,
                                       publisherID: hoorayMessage.publisherID,
                                       ackUserID: auth.userID)
            self?.hoorayRepository.requestAckHooray([ack])
        }
        
        return self.messagingService.receivedMessage
            .compactMap{ $0 as? NewHoorayMessage }
            .do(onNext: sendAck)
    }
    
    public func loadHooray(_ id: String) -> Maybe<Hooray> {
        return self.hoorayRepository.requestLoadHooray(id)
    }
    
    public func loadHoorayHoorayDetail(_ id: String) -> Observable<HoorayDetail> {
        let hoorayInLocal = self.hoorayRepository.fetchHoorayDetail(id)
        let hoorayInRemote = self.hoorayRepository.requestLoadHoorayDetail(id).mapAsOptional()
        return hoorayInLocal.asObservable()
            .concat(hoorayInRemote.asObservable())
            .compactMap{ $0 }
    }
}
