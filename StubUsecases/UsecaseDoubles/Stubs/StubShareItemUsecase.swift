//
//  StubShareItemUsecase.swift
//  UsecaseDoubles
//
//  Created by sudo.park on 2021/11/14.
//

import Foundation

import RxSwift

import Domain


open class StubShareItemUsecase: ShareReadCollectionUsecase, SharedReadCollectionLoadUsecase, SharedReadCollectionHandleUsecase {
    
    public struct Scenario {
        
        public var shareCollectionResult: Result<SharedReadCollection, Error> = .success(.dummy(0))
        public var stopShareResult: Result<Void, Error> = .success(())
        public var latestCollections: [[SharedReadCollection]] = []
        public var lastedCollectionLoadError: Error?
        
        public init() {}
    }
    
    private let scenario: Scenario
    public init(scenario: Scenario = .init()) {
        self.scenario = scenario
    }
    
    public func shareCollection(_ collection: ReadCollection) -> Maybe<SharedReadCollection> {
        return self.scenario.shareCollectionResult.asMaybe()
    }
    
    public func stopShare(collection shareID: String) -> Maybe<Void> {
        return self.scenario.stopShareResult.asMaybe()
    }
    
    public func refreshLatestSharedReadCollection() {
        
    }
    
    public var lastestSharedReadCollections: Observable<[SharedReadCollection]> {
        .empty()
    }
    
    public func loadSharedCollection(by sharedURL: URL) -> Maybe<SharedReadCollection> {
        return .empty()
    }
}
