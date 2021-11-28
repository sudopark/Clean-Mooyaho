//
//  StubReadItemRepository.swift
//  DomainTests
//
//  Created by sudo.park on 2021/09/13.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


class StubReadItemRepository: ReadItemRepository {
    
    struct Scenario {
        var myItems: Result<[ReadItem], Error> = .success(
            (0..<5).map{ ReadLink.dummy($0) } + (5..<11).map{ ReadCollection.dummy($0) }
        )
        var collectionItems: Result<[ReadItem], Error> = .success(
            [ReadCollection.dummy(0), ReadCollection.dummy(1)]
        )
        
        var collection: Result<ReadCollection, Error> = .success(.dummy(0, parent: 9))
        
        var updateCollectionResult: Result<Void, Error> = .success(())
        var updateLinkResult: Result<Void, Error> = .success(())
        
        var updateWithParamsResult: Result<Void, Error> = .success(())
        
        var ulrAndLinkItemMap = [String: ReadLink]()
        
        var loadReadLinkResult: Result<ReadLink, Error> = .success(.dummy(0, parent: 0))
        
        var sugegstNextReadResult: Result<[ReadItem], Error> = .success([ReadCollection.dummy(0, parent: nil)])
        var fetchCurrentReadingLinkResult: Result<[ReadLink], Error> = .success([ReadLink.dummy(0, parent: nil)])
        var favoriteItemIDs: [[String]] = [["some"], ["some", "new"]]
    }
    
    private var scenario: Scenario
    init(scenario: Scenario = .init()) {
        self.scenario = scenario
    }
    
    func requestLoadMyItems(for memberID: String?) -> Observable<[ReadItem]> {
        return self.scenario.myItems.asMaybe().asObservable()
    }
    
    func requestLoadCollectionItems(collectionID: String) -> Observable<[ReadItem]> {
        return self.scenario.collectionItems.asMaybe().asObservable()
    }
    
    func requestUpdateCollection(_ collection: ReadCollection) -> Maybe<Void> {
        return self.scenario.updateCollectionResult.asMaybe()
    }
    
    func requestUpdateLink(_ link: ReadLink) -> Maybe<Void> {
        return self.scenario.updateLinkResult.asMaybe()
    }
    
    public var collectionMocking: ReadCollection?
    func requestLoadCollection(_ collectionID: String) -> Observable<ReadCollection> {
        return self.collectionMocking.map { .just($0) }
            ?? self.scenario.collection.asMaybe().asObservable()
    }
    
    func requestLoadReadLinkItem(_ itemID: String) -> Observable<ReadLink> {
        return self.scenario.loadReadLinkResult.asMaybe().asObservable()
    }
    
    func requestUpdateItem(_ params: ReadItemUpdateParams) -> Maybe<Void> {
        return scenario.updateWithParamsResult.asMaybe()
    }
    
    func requestFindLinkItem(using url: String) -> Maybe<ReadLink?> {
        let item = self.scenario.ulrAndLinkItemMap[url]
        return .just(item)
    }
    
    func requestRemove(item: ReadItem) -> Maybe<Void> {
        return .just()
    }
    
    func requestSearchReadItem(by keyword: String) -> Maybe<[SearchReadItemIndex]> {
        return .empty()
    }
    
    func requestSuggestNextReadItems(for memberID: String?, size: Int) -> Maybe<[ReadItem]> {
        return self.scenario.sugegstNextReadResult.asMaybe()
    }
    
    func requestLoadItems(ids: [String]) -> Maybe<[ReadItem]> {
        let items = ids.map { ReadLink(uid: $0, link: "link-\($0)", createAt: .now(), lastUpdated: .now()) }
        return .just(items)
    }
    
    func fetchUserReadingLinks() -> Maybe<[ReadLink]> {
        return self.scenario.fetchCurrentReadingLinkResult.asMaybe()
    }
    
    func requestRefreshFavoriteItemIDs() -> Observable<[String]> {
        guard self.scenario.favoriteItemIDs.isNotEmpty else { return .empty() }
        let first = self.scenario.favoriteItemIDs.removeFirst()
        return .just(first)
    }
    
    func toggleItemIsFavorite(_ id: String, toOn: Bool) -> Maybe<Void> {
        return .just()
    }
    
    func updateLinkItemIsReading(_ id: String) { }
}
