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
        public var categoriesWithPaging: [[ItemCategory]] = []
        public var updateCategoryWithValidatingReuslt: Result<Void, Error> = .success(())
        
        public init () {}
    }
    private var scenario: Scenario
    public init(scenario: Scenario = Scenario()) {
        self.scenario = scenario
    }
    
    
    public func categories(for ids: [String]) -> Observable<[ItemCategory]> {
        return .from(self.scenario.categories)
    }
    
    public func updateCategories(_ categories: [ItemCategory]) -> Maybe<Void> {
        return self.scenario.updateResult.asMaybe()
    }
    
    public var didUpdateRequestedCategory: ItemCategory?
    public func updateCategoryIfNotExist(_ category: ItemCategory) -> Maybe<Void> {
        self.didUpdateRequestedCategory = category
        return self.scenario.updateCategoryWithValidatingReuslt.asMaybe()
    }
    
    public func loadCategories(earilerThan createTime: TimeStamp) -> Maybe<[ItemCategory]> {
        guard self.scenario.categoriesWithPaging.isNotEmpty else { return .just([]) }
        let first = self.scenario.categoriesWithPaging.removeFirst()
        return .just(first)
    }
    
    public func deleteCategory(_ itemID: String) -> Maybe<Void> {
        return .just()
    }
}
