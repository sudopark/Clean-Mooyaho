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
        public init() {}
    }
    
    private let scenario: Scenario
    
    public init(scenario: Scenario = .init()) {
        self.scenario = scenario
    }
    
    public func preparePermission() -> Maybe<Bool> {
        return .just(true)
    }
    
    public func scheduleRemind(for itemID: ReadItem,
                               at futureTime: TimeStamp) -> Maybe<ReadRemind> {
        return .just(.dummy(0))
    }
    
    public func cancelRemind(_ remind: ReadRemind) -> Maybe<Void> {
        return .just()
    }
    
    public func readReminds(for itemIDs: [String]) -> Observable<[ReadRemind]> {
        return .just([])
    }
    
    public func handleReminder(_ readReminder: ReadRemindMessage) -> Maybe<Void> {
        return .just()
    }
}
