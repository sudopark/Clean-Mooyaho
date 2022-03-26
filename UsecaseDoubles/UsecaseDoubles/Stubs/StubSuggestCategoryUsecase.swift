//
//  StubSuggestCategoryUsecase.swift
//  UsecaseDoubles
//
//  Created by sudo.park on 2021/10/10.
//

import Foundation

import RxSwift

import Domain


public class StubSuggestCategoryUsecase: SuggestCategoryUsecase {
    
    public struct Scenario {
        public var latestCategories: [SuggestCategory] = []
        public var suggestResultMap: [String: [SuggestCategoryCollection]] = [:]
        
        public init() {}
    }
    
    private let scenario: Scenario
    public init(scenario: Scenario = .init()) {
        self.scenario = scenario
    }
    
    private let fakeSuggesting = BehaviorSubject<Bool>(value: false)
    private let fakeResult = PublishSubject<SuggestCategoryCollection?>()
    private var currentQuery: String?
    private var pageIndex: Int = 0
    
    public func startSuggestCategories(query: String) {
        self.fakeSuggesting.onNext(true)
        self.currentQuery = query
        
        if let result = self.scenario.suggestResultMap[query]?.first {
            self.fakeResult.onNext(result)
        } else {
            self.fakeResult.onNext(.empty(query))
        }
    }
    
    public func stopSuggest() {
        self.fakeSuggesting.onNext(false)
        self.currentQuery = nil
        self.pageIndex = 0
        self.fakeResult.onNext(nil)
    }
    
    public func loadMore() {
        guard let query = self.currentQuery,
              let results = self.scenario.suggestResultMap[query],
              let result = results[safe: pageIndex + 1] else { return }
        
        self.fakeResult.onNext(result)
        self.pageIndex += 1
    }
    
    public func loadLatestCategories() -> Observable<[SuggestCategory]> {
        return .just(self.scenario.latestCategories)
    }
    
    public var suggestedCategories: Observable<SuggestCategoryCollection?> {
        return self.fakeResult
            .asObservable()
    }
    
    public var isSuggesting: Observable<Bool> {
        return self.fakeSuggesting
            .distinctUntilChanged()
    }
}
