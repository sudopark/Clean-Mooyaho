//
//  StubShareItemRepository.swift
//  DomainTests
//
//  Created by sudo.park on 2021/11/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


class StubShareItemRepository: ShareItemRepository {
    
    var shareCollectionResult: Result<SharedReadCollection, Error> = .success(.dummy(0))
    func requestShareCollection(_ collectionID: String) -> Maybe<SharedReadCollection> {
        return self.shareCollectionResult.asMaybe()
    }
    
    var stopShareItemResult: Result<Void, Error> = .success(())
    func requestStopShare(readCollection shareID: String) -> Maybe<Void> {
        return self.stopShareItemResult.asMaybe()
    }
    
    var latestSharedCollections: [SharedReadCollection]? = []
    func requestLoadLatestsSharedCollections() -> Observable<[SharedReadCollection]> {
        return latestSharedCollections.map { .just($0) } ?? .error(ApplicationErrors.notFound)
    }
    
    var loadSharedCollectionResult: Result<SharedReadCollection, Error> = .success(.dummy(0))
    func requestLoadSharedCollection(by shareID: String) -> Maybe<SharedReadCollection> {
        return self.loadSharedCollectionResult.asMaybe()
    }
    
    var loadMySharingCollectionIDsResults: [[String]] = []
    func requestLoadMySharingCollectionIDs() -> Observable<[String]> {
        guard self.loadMySharingCollectionIDsResults.isNotEmpty else { return .empty() }
        let first = self.loadMySharingCollectionIDsResults.removeFirst()
        return .just(first)
    }
    
    func requestLoadMySharingCollection(_ collectionID: String) -> Maybe<SharedReadCollection> {
        return .just(.dummy(0))
    }
    
    var loadSharedSubCollectionItemsResult: Result<[SharedReadItem], Error> = .success([SharedReadCollection.dummy(0)])
    func requestLoadSharedCollectionSubItems(collectionID: String) -> Maybe<[SharedReadItem]> {
        return loadSharedSubCollectionItemsResult.asMaybe()
    }
    
    var removeFromSharedListResult: Result<Void, Error> = .success(())
    func requestRemoveFromSharedList(_ sharedID: String) -> Maybe<Void> {
        return self.removeFromSharedListResult.asMaybe()
    }
    
    var loadAllSharedCollectionIDsResult: Result<[String], Error> = .success([])
    func requestLoadAllSharedCollectionIDs() -> Maybe<[String]> {
        return self.loadAllSharedCollectionIDsResult.asMaybe()
    }
    
    var loadSharedCollectionError: Error?
    func requestLoadSharedCollections(by shareIDs: [String]) -> Maybe<[SharedReadCollection]> {
        if let error = self.loadSharedCollectionError {
            return .error(error)
        } else {
            let collections: [SharedReadCollection] = shareIDs.map {
                return SharedReadCollection(shareID: $0, uid: "c:\($0)",
                                            name: "nae", createdAt: .now(), lastUpdated: .now())
            }
            return .just(collections)
        }
    }
    
    var loadSharedMemberIDResult: Result<[String], Error> = .success([])
    func requestLoadSharedMemberIDs(of collectionShareID: String) -> Maybe<[String]> {
        return self.loadSharedMemberIDResult.asMaybe()
    }
}
