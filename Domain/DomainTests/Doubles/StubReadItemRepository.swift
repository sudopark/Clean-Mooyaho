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
        var collection: Result<[ReadItem], Error> = .success(
            [ReadCollection.dummy(0), ReadCollection.dummy(1)]
        )
        
        var makeNewCollectionResult: Result<Void, Error> = .success(())
        var updateCollectionResult: Result<Void, Error> = .success(())
        var saveLinkResult: Result<Void, Error> = .success(())
    }
    
    private let scenario: Scenario
    init(scenario: Scenario) {
        self.scenario = scenario
    }
    
    func requestLoadMyItems(for memberID: String?) -> Observable<[ReadItem]> {
        return self.scenario.myItems.asMaybe().asObservable()
    }
    
    func requestLoadCollectionItems(for memberID: String?, collectionID: String) -> Observable<[ReadItem]> {
        return self.scenario.collection.asMaybe().asObservable()
    }
    
    func requestMakeCollection(for memberID: String?, collection: ReadCollection) -> Observable<Void> {
        return self.scenario.makeNewCollectionResult.asMaybe().asObservable()
    }
    
    func requestUpdateCollection(for memberID: String?, newCollection: ReadCollection) -> Observable<Void> {
        return self.scenario.updateCollectionResult.asMaybe().asObservable()
    }
    
    func requestSaveLink(for memberID: String?, link: ReadLink) -> Observable<Void> {
        return self.scenario.saveLinkResult.asMaybe().asObservable()
    }
}
