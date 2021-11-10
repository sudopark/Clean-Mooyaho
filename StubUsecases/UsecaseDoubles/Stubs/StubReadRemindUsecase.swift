//
//  StubReadRemindUsecase.swift
//  UsecaseDoubles
//
//  Created by sudo.park on 2021/10/22.
//

import Foundation

import RxSwift

import Domain


open class StubReadRemindUsecase: ReadRemindUsecase, RemindOptionUsecase {
    
    public struct Scenario {

        public var hasPermission: Bool = true
        public var defaultRemindtime: RemindTime = .default
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
    
    public func handleReminder(_ readReminder: ReadRemindMessage) -> Maybe<Void> {
        return .just()
    }
    
    public func loadDefaultRemindTime() -> Maybe<RemindTime> {
        return .just(self.scenario.defaultRemindtime)
    }
    
    public func updateDefaultRemindTime(_ time: RemindTime) -> Maybe<Void> {
        return .just()
    }
}
