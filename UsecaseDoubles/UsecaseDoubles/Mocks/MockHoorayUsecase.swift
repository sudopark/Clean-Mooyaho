//
//  MockHoorayUsecase.swift
//  UsecaseDoubles
//
//  Created by sudo.park on 2021/05/29.
//

import Foundation

import RxSwift

import Domain
import UnitTestHelpKit


open class MockHoorayUsecase: HoorayUsecase, Mocking {
    
    public init() {}
    
    open func isAvailToPublish() -> Maybe<Void> {
        return self.resolve(key: "isAvailToPublish") ?? .empty()
    }
    
    open func publish(newHooray hoorayForm: NewHoorayForm, withNewPlace placeForm: NewPlaceForm?) -> Maybe<Hooray> {
        self.verify(key: "publish:newHooray", with: (hoorayForm, placeForm))
        return self.resolve(key: "publish:newHooray") ?? .empty()
    }
    
    public let mockHoorayAck = PublishSubject<HoorayAckMessage>()
    open var receiveHoorayAck: Observable<HoorayAckMessage> {
        return mockHoorayAck.asObservable()
    }
    
    public let mockHoorayReaction = PublishSubject<HoorayReactionMessage>()
    open var receiveHoorayReaction: Observable<HoorayReactionMessage> {
        return mockHoorayReaction.asObservable()
    }
    
    open func loadNearbyRecentHoorays(at location: Coordinate) -> Maybe<[Hooray]> {
        return self.resolve(key: "loadNearbyRecentHoorays") ?? .empty()
    }
    
    public let mockNewHooray = PublishSubject<NewHoorayMessage>()
    open var newReceivedHoorayMessage: Observable<NewHoorayMessage> {
        return mockNewHooray.asObservable()
    }
    
    private let mockPublishedNewHooray = PublishSubject<Hooray>()
    public var newHoorayPublished: Observable<Hooray> {
        return self.mockPublishedNewHooray.asObservable()
    }
    
    public func loadHooray(_ id: String) -> Maybe<Hooray> {
        return self.resolve(key: "loadHooray") ?? .empty()
    }
    
    public func loadHoorayHoorayDetail(_ id: String) -> Observable<HoorayDetail> {
        return self.resolve(key: "loadHoorayHoorayDetail") ?? .empty()
    }
}
