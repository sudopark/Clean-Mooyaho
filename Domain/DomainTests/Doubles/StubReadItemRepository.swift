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
    }
    
    private let scenario: Scenario
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
    
    func requestUpdateItem(_ params: ReadItemUpdateParams) -> Maybe<Void> {
        return scenario.updateWithParamsResult.asMaybe()
    }
}
