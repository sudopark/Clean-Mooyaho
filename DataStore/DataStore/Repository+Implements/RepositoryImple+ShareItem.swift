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
    
    public func requestStopShare(readCollection shareID: String) -> Maybe<Void> {
        return self.shareItemRemote.requestStopShare(shareID: shareID)
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
