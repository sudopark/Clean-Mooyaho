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
    
    public func requestShareCollection(_ collectionID: String) -> Maybe<SharedReadCollection> {
        
        let updateCache: (SharedReadCollection) -> Void = { [weak self] shared in
            self?.updateSharingCollectionIDs { oldIDs in
                return oldIDs.filter { $0 != collectionID } + [collectionID]
            }
        }
        return self.shareItemRemote.requestShare(collectionID: collectionID)
            .do(onNext: updateCache)
    }
    
    public func requestStopShare(readCollection collectionID: String) -> Maybe<Void> {
        
        let updateCache: () -> Void = { [weak self]  in
            self?.updateSharingCollectionIDs { oldIDs in
                return oldIDs.filter { $0 != collectionID }
            }
        }
        
        return self.shareItemRemote.requestStopShare(collectionID: collectionID)
            .do(onNext: updateCache)
    }
    
    public func requestLoadMySharingCollectionIDs() -> Observable<[String]> {
        let cachedIDsWithoutError = self.shareItemLocal.fetchMySharingItemIDs().catchAndReturn([])
        
        let updateCache: ([String]) -> Void = { [weak self] ids in
            self?.updateSharingCollectionIDs { _ in ids }
        }
        let reloadIDs = self.shareItemRemote.requestLoadMySharingCollectionIDs()
            .do(onNext: updateCache)
        
        return cachedIDsWithoutError.asObservable()
            .concat(reloadIDs)
    }
    
    private func updateSharingCollectionIDs(_ mutate: @escaping ([String]) -> [String]) {
        
        let loadCache = self.shareItemLocal.fetchMySharingItemIDs().catchAndReturn([])
        let thenUpdateCache: ([String]) -> Maybe<Void> = { [weak self] cached in
            let newIDs = mutate(cached)
            return self?.shareItemLocal.updateMySharingItemIDs(newIDs) ?? .empty()
        }
        loadCache
            .flatMap(thenUpdateCache)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
    
    public func requestLoadLatestsSharedCollections() -> Observable<[SharedReadCollection]> {
        let fetchCollectionsWithoutError = self.shareItemLocal.fetchLatestSharedCollections()
            .catchAndReturn([])
        let updateLocal: ([SharedReadCollection]) -> Void = { [weak self] collections in
            self?.replaceSharedCollections(collections)
        }
        let collectionsInRemote = self.shareItemRemote.requestLoadLatestSharedCollections()
            .do(onNext: updateLocal)
                
        return fetchCollectionsWithoutError
            .asObservable()
            .concat(collectionsInRemote)
    }
    
    private func replaceSharedCollections(_ collections: [SharedReadCollection]) {
        self.shareItemLocal.replaceLastSharedCollections(collections)
            .subscribe()
            .disposed(by: self.disposeBag)
    }

    
    public func requestLoadSharedCollection(by shareID: String) -> Maybe<SharedReadCollection> {
        
        let updateLocal: (SharedReadCollection) -> Void = { [weak self] collection in
            self?.saveSharedCollection(collection)
        }
        
        return self.shareItemRemote.requestLoadSharedCollection(by: shareID)
            .do(onNext: updateLocal)
    }
    
    private func saveSharedCollection(_ collection: SharedReadCollection) {
        self.shareItemLocal.saveSharedCollection(collection)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
}
