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
        public var updateResult: Result<Void, Error> = .success(())
        
        public init () {}
    }
    private let scenario: Scenario
    public init(scenario: Scenario = Scenario()) {
        self.scenario = scenario
    }
    
    
    public func categories(for ids: [String]) -> Observable<[ItemCategory]> {
        return .from(self.scenario.categories)
    }
    
    public func updateCategories(_ categories: [ItemCategory]) -> Maybe<Void> {
        return self.scenario.updateResult.asMaybe()
    }
    
    public func loadCategories(earilerThan createTime: TimeStamp) -> Maybe<[ItemCategory]> {
        return .empty()
    }
    
    public func deleteCategory(_ itemID: String) -> Maybe<Void> {
        return .empty()
    }
}
