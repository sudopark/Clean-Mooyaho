//
//  RepositoryImple+ShareItem.swift
//  DataStore
//
//  Created by sudo.park on 2021/11/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


public protocol ShareItemReposiotryDefImpleDependency: AnyObject {
    
    var disposeBag: DisposeBag { get }
    var shareItemLocal: ShareItemLocalStorage { get }
    var shareItemRemote: ShareItemRemote { get }
}


extension ShareItemRepository where Self: ShareItemReposiotryDefImpleDependency {
    
    public func requestShareCollection(_ collection: ReadCollection) -> Maybe<SharedReadCollection> {
        return self.shareItemRemote.requestShare(collection: collection)
    }
    
    public func requestStopShare(readCollection collectionID: String) -> Maybe<Void> {
        return self.shareItemRemote.requestStopShare(collectionID: collectionID)
    }
    
    public func requestLoadLatestsSharedCollections() -> Observable<[SharedReadCollection]> {
        let fetchCollectionsWithoutError = self.shareItemLocal.fetchLatestSharedCollections()
            .catchAndReturn([])
        let updateLocal: ([SharedReadCollection]) -> Void = { [weak self] collections in
            self?.updateSharedCollections(collections)
        }
        let collectionsInRemote = self.shareItemRemote.requestLoadLatestSharedCollections()
            .do(onNext: updateLocal)
                
        return fetchCollectionsWithoutError
            .asObservable()
            .concat(collectionsInRemote)
    }

    
    public func requestLoadSharedCollection(_ collectionID: String) -> Maybe<SharedReadCollection> {
        
        let updateLocal: (SharedReadCollection) -> Void = { [weak self] collection in
            self?.updateSharedCollections([collection])
        }
        
        return self.shareItemRemote.requestLoadSharedCollection(collectionID)
            .do(onNext: updateLocal)
    }
    
    private func updateSharedCollections(_ collections: [SharedReadCollection]) {
        self.shareItemLocal.updateLastSharedCollections(collections)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
}
