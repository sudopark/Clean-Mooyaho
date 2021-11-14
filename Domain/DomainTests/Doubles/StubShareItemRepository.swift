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
    func requestShareCollection(_ collection: ReadCollection) -> Maybe<SharedReadCollection> {
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
}
