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
    }
    
    private let scenario: Scenario
    init(scenario: Scenario = Scenario()) {
        self.scenario = scenario
    }
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
}
