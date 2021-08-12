//
//  BaseStubHoorayUsecase.swift
//  UsecaseDoubles
//
//  Created by sudo.park on 2021/07/30.
//

import Foundation

import RxSwift

import Domain


public class BaseStubHoorayUsecase: HoorayUsecase {
    
    public struct Scenario {
        public var isAvailToPublishHooray: Result<Void, Error> = .success(())
        public var publishNewHoorayResult: Result<Hooray, Error> = .success(Hooray.dummy(0))
        public var nearbyRecentHoorays: Result<[Hooray], Error> = .success([])
        
        public init() { }
    }
    
    private let scenario: Scenario
    public init(_ scenario: Scenario = Scenario()) {
        self.scenario = scenario
    }
    
    public func isAvailToPublish() -> Maybe<Void> {
        return self.scenario.isAvailToPublishHooray.asMaybe()
    }
    
    public func publish(newHooray hoorayForm: NewHoorayForm, withNewPlace placeForm: NewPlaceForm?) -> Maybe<Hooray> {
        return self.scenario.publishNewHoorayResult.asMaybe()
            .do(afterNext: {
                self.newHooraySubject.onNext($0)
            })
    }
    
    public let mockReceivedHoorayAck = PublishSubject<HoorayAckMessage>()
    public var receiveHoorayAck: Observable<HoorayAckMessage> {
        return self.mockReceivedHoorayAck.asObservable()
    }
    
    public let mockReceivedReaction = PublishSubject<HoorayReactionMessage>()
    public var receiveHoorayReaction: Observable<HoorayReactionMessage> {
        return self.mockReceivedReaction.asObservable()
    }
    
    public func loadNearbyRecentHoorays(_ userID: String, at location: Coordinate) -> Maybe<[Hooray]> {
        return self.scenario.nearbyRecentHoorays.asMaybe()
    }
    
    public let mockNewHooray = PublishSubject<NewHoorayMessage>()
    public var newReceivedHooray: Observable<NewHoorayMessage> {
        return self.mockNewHooray.asObservable()
    }
    
    private let newHooraySubject = PublishSubject<Hooray>()
    public var newHoorayPublished: Observable<Hooray> {
        return self.newHooraySubject.asObservable()
    }
}
