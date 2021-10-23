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
        
        public var reminds: Result<[ReadRemind], Error> = .success([])
        public init() { }
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
        guard let items = try? self.fakeReminds.value() else { return .just() }
        let newItems = items.filter { $0.uid != remind.uid }
        self.fakeReminds.onNext(newItems)
        return .just()
    }
    
    private let fakeReminds: BehaviorSubject<[ReadRemind]?> = .init(value: nil)
    public func readReminds(for itemIDs: [String]) -> Observable<[ReadRemind]> {
        return self.fakeReminds.compactMap { $0 }
            .do(onSubscribed: {
                guard let reminds = try? self.scenario.reminds.get() else { return }
                self.fakeReminds.onNext(reminds)
            })
    }
    
    public func handleReminder(_ readReminder: ReadRemindMessage) -> Maybe<Void> {
        return .just()
    }
}
