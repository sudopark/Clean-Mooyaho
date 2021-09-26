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
        var localCollectionItems: Result<[ReadItem], Error> = .success(
            [ReadCollection.dummy(0), ReadCollection.dummy(1)]
        )
        
        var localCollection: Result<ReadCollection, Error> = .success(.dummy(0, parent: 9))
        
        var remoteMyItems: Result<[ReadItem], Error> = .success(
            (0..<5).map{ ReadLink.dummy($0) } + (5..<11).map{ ReadCollection.dummy($0) }
        )
        var remoteCollectionItems: Result<[ReadItem], Error> = .success(
            [ReadCollection.dummy(0), ReadCollection.dummy(1)]
        )
        
        var remoteCollection: Result<ReadCollection, Error> = .success(.dummy(0, parent: 10))
        
        var updateCollectionResult: Result<Void, Error> = .success(())
        var updateLinkResult: Result<Void, Error> = .success(())
    }
    
    private let scenario: Scenario
    init(scenario: Scenario) {
        self.scenario = scenario
    }
    
    func fetchMyItems() -> Maybe<[ReadItem]> {
        return self.scenario.myItems.asMaybe()
    }
    
    func requestLoadMyItems(for memberID: String) -> Observable<[ReadItem]> {
        return self.scenario.myItems.asMaybe().asObservable()
            .concat(self.scenario.remoteMyItems.asMaybe())
    }
    
    func fetchCollectionItems(collectionID: String) -> Maybe<[ReadItem]> {
        return self.scenario.localCollectionItems.asMaybe()
    }
    
    func requestLoadCollectionItems(collectionID: String) -> Observable<[ReadItem]> {
        return self.scenario.localCollectionItems.asMaybe().asObservable()
            .concat(self.scenario.remoteCollectionItems.asMaybe())
    }

    func updateCollection(_ collection: ReadCollection) -> Maybe<Void> {
        return self.scenario.updateCollectionResult.asMaybe()
    }
    
    func requestUpdateCollection(_ collection: ReadCollection) -> Maybe<Void> {
        return self.scenario.updateCollectionResult.asMaybe()
    }
    
    func updateLink(_ link: ReadLink) -> Maybe<Void> {
        return self.scenario.updateLinkResult.asMaybe()
    }
    
    func requestUpdateLink(_ link: ReadLink) -> Maybe<Void> {
        return self.scenario.updateLinkResult.asMaybe()
    }
    
    func fetchCollection(_ collectionID: String) -> Maybe<ReadCollection> {
        return self.scenario.localCollection.asMaybe()
    }
    
    func requestLoadCollection(for memberID: String, collectionID: String) -> Observable<ReadCollection> {
        return self.scenario.remoteCollection.asMaybe().asObservable()
    }
}
