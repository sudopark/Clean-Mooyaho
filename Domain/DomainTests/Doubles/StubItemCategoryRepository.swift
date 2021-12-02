//
//  StubItemCategoryRepository.swift
//  DomainTests
//
//  Created by sudo.park on 2021/10/08.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


class StubItemCategoryRepository: ItemCategoryRepository {
    
    struct Scenario {
        var localCategories: Result<[ItemCategory], Error> = .success([])
        var remoteCategories: Result<[ItemCategory], Error> = .success([])
        var latestCategories: Result<[SuggestCategory], Error> = .success([])
        var loadWithPagingResult: Result<[ItemCategory], Error> = .success([])
    }
    
    private let scenario: Scenario
    init(scenario: Scenario = Scenario()) {
        self.scenario = scenario
    }
    
    var suggestResultMocking: SuggestCategoryCollection?
}


extension StubItemCategoryRepository {
    
    func fetchCategories(_ ids: [String]) -> Maybe<[ItemCategory]> {
        return self.scenario.localCategories.asMaybe()
    }
    
    func requestLoadCategories(_ ids: [String]) -> Maybe<[ItemCategory]> {
        return self.scenario.remoteCategories.asMaybe()
    }
    
    func updateCategories(_ categories: [ItemCategory]) -> Maybe<Void> {
        return .just()
    }
    
    func loadLatestCategories() -> Maybe<[SuggestCategory]> {
        return self.scenario.latestCategories.asMaybe()
    }
    
    func suggestItemCategory(name: String, cursor: String?) -> Maybe<SuggestCategoryCollection> {
        guard let mocking = self.suggestResultMocking else {
            return .empty()
        }
        return .just(mocking)
    }
    
    
    func requestLoadCategories(earilerThan creatTime: TimeStamp,
                               pageSize: Int) -> Maybe<[ItemCategory]> {
        return self.scenario.loadWithPagingResult.asMaybe()
    }
    
    func requestDeleteCategory(_ itemID: String) -> Maybe<Void> {
        return .just()
    }
}
