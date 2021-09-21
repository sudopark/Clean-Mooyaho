//
//  StubReadIttemUsecase.swift
//  UsecaseDoubles
//
//  Created by sudo.park on 2021/09/19.
//

import Foundation

import RxSwift

import Domain

open class StubReadItemUsecase: ReadItemUsecase {
    
    public struct Scenario {
        public var myItems: Result<[ReadItem], Error> = .success([])
        public var collectionItems: Result<[ReadItem], Error> = .success([])
        public var updateCollectionResult: Result<Void, Error> = .success(())
        public var updateLinkResult: Result<Void, Error> = .success(())
        public var sortOrder: Result<ReadCollectionItemSortOrder, Error> = .success(.default)
        public var shrinkModeIsOn: Bool = false
        
        public init() {}
    }
    private var scenario: Scenario
    public init(scenario: Scenario = Scenario()) {
        self.scenario = scenario
    }
    
    open func loadMyItems() -> Observable<[ReadItem]> {
        return self.scenario.myItems.asMaybe().asObservable()
    }
    
    open func loadCollectionItems(_ collectionID: String) -> Observable<[ReadItem]> {
        return self.scenario.collectionItems.asMaybe().asObservable()
    }
    
    open func updateCollection(_ newCollection: ReadCollection) -> Maybe<Void> {
        return self.scenario.updateLinkResult.asMaybe()
    }
    
    open func updateLink(_ link: ReadLink) -> Maybe<Void> {
        return self.scenario.updateLinkResult.asMaybe()
    }
    
    open func loadShrinkModeIsOnOption() -> Maybe<Bool> {
        return .just(self.scenario.shrinkModeIsOn)
    }
    
    open func updateIsShrinkModeIsOn(_ newvalue: Bool) -> Maybe<Void> {
        self.scenario.shrinkModeIsOn = newvalue
        return .just()
    }
    
    open func loadLatestSortOption(for collectionID: String) -> Maybe<ReadCollectionItemSortOrder> {
        return self.scenario.sortOrder.asMaybe()
    }
    
    open func loadCustomOrder(for collectionID: String) -> Maybe<[String]> {
        return .empty()
    }
    
    open func updateSortOption(for collectionID: String, to newValue: ReadCollectionItemSortOrder) -> Maybe<Void> {
        return .empty()
    }
    
    open func updateCustomOrder(for collectionID: String, itemIDs: [String]) -> Maybe<Void> {
        return .empty()
    }
}
