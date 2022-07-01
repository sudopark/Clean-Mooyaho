//
//  StubItemCategoryUsecase.swift
//  UsecaseDoubles
//
//  Created by sudo.park on 2021/10/09.
//

import Foundation

import RxSwift

import Domain
import Extensions


open class StubItemCategoryUsecase: ReadItemCategoryUsecase {
    
    public struct Scenario {
        public var categories: [[ItemCategory]] = []
        public var updateResult: Result<Void, Error> = .success(())
        public var categoriesWithPaging: [[ItemCategory]] = []
        public var updateCategoryWithValidatingReuslt: Result<ItemCategory, Error> = .success(.dummy(0))
        
        public init () {}
    }
    private var scenario: Scenario
    public init(scenario: Scenario = Scenario()) {
        self.scenario = scenario
    }
    
    
    public func categories(for ids: [String]) -> Observable<[ItemCategory]> {
        return .from(self.scenario.categories)
    }
    
    open func updateCategories(_ categories: [ItemCategory]) -> Maybe<Void> {
        return self.scenario.updateResult.asMaybe()
    }
    
    public var didUpdateRequestedCategory: UpdateCategoryAttrParams?
    public func updateCategory(by params: UpdateCategoryAttrParams,
                               from: ItemCategory) -> Maybe<ItemCategory> {
        self.didUpdateRequestedCategory = params
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
