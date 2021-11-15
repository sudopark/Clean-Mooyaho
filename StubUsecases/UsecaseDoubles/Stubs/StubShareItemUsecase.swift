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
        
        public init() {}
    }
    
    private var scenario: Scenario
    public init(scenario: Scenario = .init()) {
        self.scenario = scenario
    }
    
    public func shareCollection(_ collection: ReadCollection) -> Maybe<SharedReadCollection> {
        return self.scenario.shareCollectionResult.asMaybe()
    }
    
    public func stopShare(collection shareID: String) -> Maybe<Void> {
        return self.scenario.stopShareResult.asMaybe()
    }
    
    private let fakeLatestSharedCollections = PublishSubject<[SharedReadCollection]>()
    public func refreshLatestSharedReadCollection() {
        guard self.scenario.latestCollections.isNotEmpty else { return }
        let first = scenario.latestCollections.removeFirst()
        self.fakeLatestSharedCollections.onNext(first)
    }
    
    public var lastestSharedReadCollections: Observable<[SharedReadCollection]> {
        return self.fakeLatestSharedCollections
            .asObservable()
    }
    
    public func loadSharedCollection(by sharedURL: URL) -> Maybe<SharedReadCollection> {
        return .empty()
    }
}
