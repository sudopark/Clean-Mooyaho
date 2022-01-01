//
//  StubShareItemUsecase.swift
//  UsecaseDoubles
//
//  Created by sudo.park on 2021/11/14.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import UnitTestHelpKit


open class StubShareItemUsecase: ShareReadCollectionUsecase, SharedReadCollectionLoadUsecase, SharedReadCollectionUpdateUsecase, SharedReadCollectionHandleUsecase, Mocking {
    
    public struct Scenario {
        
        public var shareCollectionResult: Result<SharedReadCollection, Error> = .success(.dummy(0))
        public var stopShareResult: Result<Void, Error> = .success(())
        public var latestCollections: [[SharedReadCollection]] = []
        public var mySharingCollectionIDs: [[String]] = []
        public var mySharingCollectionResult: Result<SharedReadCollection, Error> = .success(.dummy(0))
        public var loadSharedColectionResult: Result<SharedReadCollection, Error> = .success(.dummy(0))
        public var loadSharedCollectionSubItemsResult: Result<[SharedReadItem], Error> = .success([
            SharedReadCollection.dummySubCollection(0), SharedReadLink.dummy(1)
        ])
        public var removeResult: Result<Void, Error> = .success(())
        public var loadSharedMemberIDsResult: Result<[String], Error> = .success([])
        
        public init() {}
    }
    
    public var scenario: Scenario
    public init(scenario: Scenario = .init()) {
        self.scenario = scenario
    }
    
    public func shareCollection(_ collectionID: String) -> Maybe<SharedReadCollection> {
        return self.scenario.shareCollectionResult.asMaybe()
            .do(onNext: { _ in
                let newIDs = self.fakeSharingCollectionIDs.value.filter { $0 != collectionID } + [collectionID]
                self.fakeSharingCollectionIDs.accept(newIDs)
            })
    }
    
    public func stopShare(collection collectionID: String) -> Maybe<Void> {
        return self.scenario.stopShareResult.asMaybe()
            .do(onNext: {
                let newIDs = self.fakeSharingCollectionIDs.value.filter { $0 != collectionID }
                self.fakeSharingCollectionIDs.accept(newIDs)
            })
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
    
    public func canHandleURL(_ url: URL) -> Bool {
        return true
    }
    
    public func loadSharedCollection(by sharedURL: URL) -> Maybe<SharedReadCollection> {
        return self.scenario.loadSharedColectionResult.asMaybe()
    }
    
    public func refreshMySharingColletionIDs() {
        self.verify(key: "refreshMySharingColletionIDs")
        guard self.scenario.mySharingCollectionIDs.isNotEmpty else { return }
        let first = self.scenario.mySharingCollectionIDs.removeFirst()
        self.fakeSharingCollectionIDs.accept(first)
    }
    
    private let fakeSharingCollectionIDs = BehaviorRelay<[String]>(value: [])
    public var mySharingCollectionIDs: Observable<[String]> {
        return self.fakeSharingCollectionIDs.asObservable()
    }
    
    public func loadMyharingCollection(for collectionID: String) -> Observable<SharedReadCollection> {
        return self.scenario.mySharingCollectionResult.asMaybe().asObservable()
    }
    
    public func loadSharedCollectionSubItems(collectionID: String) -> Maybe<[SharedReadItem]> {
        return self.scenario.loadSharedCollectionSubItemsResult.asMaybe()
    }
    
    public func removeFromSharedList(shareID: String) -> Maybe<Void> {
        return self.scenario.removeResult.asMaybe()
    }
    
    public func loadSharedMemberIDs(of collectionShareID: String) -> Maybe<[String]> {
        return self.scenario.loadSharedMemberIDsResult.asMaybe()
    }
}
