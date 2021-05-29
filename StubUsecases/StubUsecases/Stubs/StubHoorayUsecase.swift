//
//  StubHoorayUsecase.swift
//  StubUsecases
//
//  Created by sudo.park on 2021/05/29.
//

import Foundation

import RxSwift

import Domain
import UnitTestHelpKit


open class StubHoorayUsecase: HoorayUsecase, Stubbable {
    
    public init() {}
    
    open func isAvailToPublish(_ memberID: String) -> Maybe<Bool> {
        return self.resolve(key: "isAvailToPublish") ?? .empty()
    }
    
    open func publish(newHooray hoorayForm: NewHoorayForm, withNewPlace placeForm: NewPlaceForm?) -> Maybe<Hooray> {
        return self.resolve(key: "publish:newHooray") ?? .empty()
    }
    
    public let stubHoorayAck = PublishSubject<HoorayAckMessage>()
    open var receiveHoorayAck: Observable<HoorayAckMessage> {
        return stubHoorayAck.asObservable()
    }
    
    public let stubHoorayReaction = PublishSubject<HoorayReactionMessage>()
    open var receiveHoorayReaction: Observable<HoorayReactionMessage> {
        return stubHoorayReaction.asObservable()
    }
    
    open func loadNearbyRecentHoorays(_ userID: String, at location: Coordinate) -> Maybe<[Hooray]> {
        return self.resolve(key: "loadNearbyRecentHoorays") ?? .empty()
    }
    
    public let stubNewHooray = PublishSubject<NewHoorayMessage>()
    open var newReceivedHooray: Observable<NewHoorayMessage> {
        return stubNewHooray.asObservable()
    }
}
