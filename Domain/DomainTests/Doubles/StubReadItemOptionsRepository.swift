//
//  StubReadItemOptionsRepository.swift
//  DomainTests
//
//  Created by sudo.park on 2021/09/19.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


class StubReadItemOptionsRepository: ReadItemOptionsRepository {
    
    struct Scenario {
        var isShrinkMode: Result<Bool?, Error> = .success(false)
        var sortOrder: Result<ReadCollectionItemSortOrder?, Error> = .success(nil)
        var customOrder: Result<[String], Error> = .success([])
    }
    
    private let scenario: Scenario
    init(scenario: Scenario) {
        self.scenario = scenario
    }
    
    func fetchLastestsIsShrinkModeOn() -> Maybe<Bool?> {
        return self.scenario.isShrinkMode.asMaybe()
    }
    
    func updateLatestIsShrinkModeOn(_ newvalue: Bool) -> Maybe<Void> {
        return .just()
    }
    
    func fetchLatestSortOrder() -> Maybe<ReadCollectionItemSortOrder?> {
        return self.scenario.sortOrder.asMaybe()
    }
    
    func updateLatestSortOrder(to newValue: ReadCollectionItemSortOrder) -> Maybe<Void> {
        return .just()
    }

    func requestLoadCustomOrder(for collectionID: String) -> Observable<[String]> {
        return self.scenario.customOrder.asMaybe().asObservable()
    }
    
    func requestUpdateCustomSortOrder(for collectionID: String, itemIDs: [String]) -> Maybe<Void> {
        return .just()
    }
}
