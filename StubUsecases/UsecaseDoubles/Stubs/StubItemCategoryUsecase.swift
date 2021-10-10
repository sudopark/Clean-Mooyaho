//
//  StubItemCategoryUsecase.swift
//  UsecaseDoubles
//
//  Created by sudo.park on 2021/10/09.
//

import Foundation

import RxSwift

import Domain


open class StubItemCategoryUsecase: ReadItemCategoryUsecase {
    
    public struct Scenario {
        public var categories: [[ItemCategory]] = []
        public var makeResult: Result<ItemCategory, Error> = .success(.dummy(200))
        
        public init () {}
    }
    private let scenario: Scenario
    public init(scenario: Scenario = Scenario()) {
        self.scenario = scenario
    }
    
    
    public func categories(for ids: [String]) -> Observable<[ItemCategory]> {
        return .from(self.scenario.categories)
    }
    
    public func makeCategory(_ name: String, colorCode: String) -> Maybe<ItemCategory> {
        return self.scenario.makeResult.asMaybe()
    }
}
