//
//  BaseStubHoorayUsecase.swift
//  UsecaseDoubles
//
//  Created by sudo.park on 2021/07/30.
//

import Foundation

import RxSwift

import Domain


open class BaseStubHoorayUsecase: HoorayUsecase {
    
    public struct Scenario {
        public var isAvailToPublishHooray: Result<Void, Error> = .success(())
        public var publishNewHoorayResult: Result<Hooray, Error> = .success(Hooray.dummy(0))
        public var nearbyRecentHoorays: Result<[Hooray], Error> = .success([Hooray.dummy(0)])
        public var loadHoorayResult: Result<Hooray, Error> = .success(Hooray.dummy(0))
        public init() { }
    }
    
    private let scenario: Scenario
    public init(_ scenario: Scenario = Scenario()) {
        self.scenario = scenario
    }
    
    open func isAvailToPublish() -> Maybe<Void> {
        return self.scenario.isAvailToPublishHooray.asMaybe()
    }
    
    open func publish(newHooray hoorayForm: NewHoorayForm, withNewPlace placeForm: NewPlaceForm?) -> Maybe<Hooray> {
        return self.scenario.publishNewHoorayResult.asMaybe()
            .do(afterNext: {
                self.newHooraySubject.onNext($0)
            })
    }
    
    public let mockReceivedHoorayAck = PublishSubject<HoorayAckMessage>()
    open var receiveHoorayAck: Observable<HoorayAckMessage> {
        return self.mockReceivedHoorayAck.asObservable()
    }
    
    public let mockReceivedReaction = PublishSubject<HoorayReactionMessage>()
    open var receiveHoorayReaction: Observable<HoorayReactionMessage> {
        return self.mockReceivedReaction.asObservable()
    }
    
    open func loadNearbyRecentHoorays(at location: Coordinate) -> Maybe<[Hooray]> {
        return self.scenario.nearbyRecentHoorays.asMaybe()
    }
    
    public let mockNewHooray = PublishSubject<NewHoorayMessage>()
    open var newReceivedHoorayMessage: Observable<NewHoorayMessage> {
        return self.mockNewHooray.asObservable()
    }
    
    private let newHooraySubject = PublishSubject<Hooray>()
    open var newHoorayPublished: Observable<Hooray> {
        return self.newHooraySubject.asObservable()
    }
    
    open func loadHooray(_ id: String) -> Maybe<Hooray> {
        return self.scenario.loadHoorayResult.asMaybe()
    }
    
    open func loadHoorayHoorayDetail(_ id: String) -> Observable<HoorayDetail> {
        // TOOD: stubbing
        return .empty()
    }
}
