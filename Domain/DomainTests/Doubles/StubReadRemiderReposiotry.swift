//
//  StubReadRemiderReposiotry.swift
//  DomainTests
//
//  Created by sudo.park on 2021/10/19.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


class StubReadRemiderReposiotry: ReadRemindRepository {
    
    struct Scenario {
        var reminders: Result<[ReadRemind], Error> = .success([.dummy(0)])
        var makeReminderResult: Result<Void, Error> = .success(())
        var cancelResult: Result<Void, Error> = .success(())
    }
    
    private let scenario: Scenario
    init(scenario: Scenario = Scenario()) {
        self.scenario = scenario
    }
}


extension StubReadRemiderReposiotry {
    
    func requestLoadReadReminds(for itemIDs: [String]) -> Observable<[ReadRemind]> {
        return self.scenario.reminders.asMaybe().asObservable()
    }
    
    func requestScheduleReadRemind(_ readRemind: ReadRemind) -> Maybe<Void> {
        return self.scenario.makeReminderResult.asMaybe()
    }
    
    func requestCancelReadRemind(for uid: String) -> Maybe<Void> {
        return self.scenario.cancelResult.asMaybe()
    }
}
