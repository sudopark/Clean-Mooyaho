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
        public var collectionInfo: Result<ReadCollection, Error> = .success(.dummy(0))
        public var collectionItems: Result<[ReadItem], Error> = .success([])
        public var updateCollectionResult: Result<Void, Error> = .success(())
        public var updateLinkResult: Result<Void, Error> = .success(())
        public var refreshedSortOrder: Result<ReadCollectionItemSortOrder, Error> = .success(.default)
        public var customOrder: Result<[String], Error> = .success([])
        public var updateCustomOrderResult: Result<Void, Error> = .success(())
        public var shrinkModeIsOn: Bool = false
        public var preview: Result<LinkPreview, Error> = .success(.dummy(0))
        public var sortOption: [ReadCollectionItemSortOrder] = [.default]
        
        public init() {}
    }
    private var scenario: Scenario
    public init(scenario: Scenario = Scenario()) {
        self.scenario = scenario
    }
    
    open func loadMyItems() -> Observable<[ReadItem]> {
        return self.scenario.myItems.asMaybe().asObservable()
    }
    
    open func loadCollectionInfo(_ collectionID: String) -> Observable<ReadCollection> {
        return self.scenario.collectionInfo.asMaybe().asObservable()
    }
    
    open func loadCollectionItems(_ collectionID: String) -> Observable<[ReadItem]> {
        return self.scenario.collectionItems.asMaybe().asObservable()
    }
    
    open func updateCollection(_ newCollection: ReadCollection) -> Maybe<Void> {
        return self.scenario.updateCollectionResult.asMaybe()
    }
    
    open func updateLink(_ link: ReadLink) -> Maybe<Void> {
        return self.scenario.updateLinkResult.asMaybe()
    }
    
    private var fakeIsShrinkMode = PublishSubject<Bool>()
    open var isShrinkModeOn: Observable<Bool> {
        return self.fakeIsShrinkMode
            .startWith(self.scenario.shrinkModeIsOn)
    }
    
    open func updateLatestIsShrinkModeIsOn(_ newvalue: Bool) -> Maybe<Void> {
        self.scenario.shrinkModeIsOn = newvalue
        self.fakeIsShrinkMode.onNext(newvalue)
        return .just()
    }
    
    open func loadLatestSortOption() -> Maybe<ReadCollectionItemSortOrder> {
        return self.scenario.refreshedSortOrder.asMaybe()
    }
    
    open var sortOrder: Observable<ReadCollectionItemSortOrder> {
        return Observable.from(self.scenario.sortOption)
    }
    
    open func updateLatestSortOption(to newValue: ReadCollectionItemSortOrder) -> Maybe<Void> {
        return .empty()
    }
    
    open func customOrder(for collectionID: String) -> Observable<[String]> {
        return self.scenario.customOrder.asMaybe().asObservable()
    }
    
    open func updateCustomOrder(for collectionID: String, itemIDs: [String]) -> Maybe<Void> {
        return self.scenario.updateCustomOrderResult.asMaybe()
    }
    
    open func loadLinkPreview(_ url: String) -> Observable<LinkPreview> {
        return self.scenario.preview.asMaybe().asObservable()
    }
    
    open func updateItem(_ params: ReadItemUpdateParams) -> Maybe<Void> {
        return .just()
    }
    
    public let readItemUpdateMocking = PublishSubject<ReadItemUpdateEvent>()
    public var readItemUpdated: Observable<ReadItemUpdateEvent> {
        return self.readItemUpdateMocking.asObservable()
    }
}
