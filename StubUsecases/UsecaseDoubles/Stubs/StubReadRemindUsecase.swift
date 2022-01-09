//
//  StubReadRemindUsecase.swift
//  UsecaseDoubles
//
//  Created by sudo.park on 2021/10/22.
//

import Foundation

import RxSwift

import Domain


open class StubReadRemindUsecase: ReadRemindUsecase {
    
    public struct Scenario {

        public var hasPermission: Bool = true
        public init() { }
    }
    
    private let scenario: Scenario
    
    public init(scenario: Scenario = .init()) {
        self.scenario = scenario
    }
    
    public func preparePermission() -> Maybe<Bool> {
        return .just(self.scenario.hasPermission)
    }
    
    public var didCanceledRemindItemID: String?
    public func updateRemind(for item: ReadItem, futureTime: TimeStamp?) -> Maybe<Void> {
        if futureTime == nil {
            self.didCanceledRemindItemID = item.uid
        }
        return .just()
    }
    
    public var didRemindScheduled: TimeStamp?
    public func scheduleRemindMessage(for item: ReadItem, at futureTime: TimeStamp) -> Maybe<Void> {
        self.didRemindScheduled = futureTime
        return .just()
    }
    
    public var didRemindCanceled: Bool?
    public func cancelRemindMessage(_ item: ReadItem) -> Maybe<Void> {
        self.didRemindCanceled = true
        return .just()
    }
    
    public func handleReminder(_ readReminder: ReadRemindMessage) -> Maybe<Void> {
        return .just()
    }
}
