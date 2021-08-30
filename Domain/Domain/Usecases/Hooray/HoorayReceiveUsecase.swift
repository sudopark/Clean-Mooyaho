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
    
    func loadHoorayHoorayDetail(_ id: String) -> Observable<Hooray>
    
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
                .filter{ $0.ackUserIDs.contains(userID) == false }
            let acks = targetHoorays
                .map { HoorayAckMessage(hoorayID: $0.uid, publisherID: $0.publisherID, ackUserID: userID) }
            self?.ackReceivedHooray(acks)
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
            self?.ackReceivedHooray([ack])
        }
        
        return self.messagingService.receivedMessage
            .compactMap{ $0 as? NewHoorayMessage }
            .do(onNext: sendAck)
    }
    
    private func ackReceivedHooray(_ acks: [HoorayAckMessage]) {
        
        let ackings = acks
            .map{ self.hoorayRepository.requestAckHooray($0).subscribe() }
        self.disposeBag.insert(ackings)
    }
    
    public func loadHooray(_ id: String) -> Maybe<Hooray> {
        return self.hoorayRepository.requestLoadHooray(id)
    }
    
    public func loadHoorayHoorayDetail(_ id: String) -> Observable<Hooray> {
        let hoorayInLocal = self.hoorayRepository.fetchHooray(id)
        let hoorayInRemote = self.hoorayRepository.requestLoadHooray(id).mapAsOptional()
        return hoorayInLocal.asObservable()
            .concat(hoorayInRemote.asObservable())
            .compactMap{ $0 }
    }
}


private extension Set where Element == HoorayAckInfo {
    
    func contains(_ userID: String) -> Bool {
        let wildcardInfoForThisUser = HoorayAckInfo(ackUserID: userID, ackAt: 0)
        return self.contains(wildcardInfoForThisUser)
    }
}
