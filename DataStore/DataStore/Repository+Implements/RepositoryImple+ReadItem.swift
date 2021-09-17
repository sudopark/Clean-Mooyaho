//
//  RepositoryImple+ReadItem.swift
//  DataStore
//
//  Created by sudo.park on 2021/09/16.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


public protocol ReadItemRepositryDefImpleDependency: AnyObject {
    
    var disposeBag: DisposeBag { get }
    var readItemRemote: ReadItemRemote { get }
    var readItemLocal: ReadItemLocalStorage { get }
}

extension ReadItemRepository where Self: ReadItemRepositryDefImpleDependency {
    
    public func fetchMyItems() -> Maybe<[ReadItem]> {
        return self.readItemLocal.fetchMyItems()
    }
    
    public func requestLoadMyItems(for memberID: String) -> Observable<[ReadItem]> {
        
        let updateLocal: ([ReadItem]) -> Void = { [weak self] items in
            guard let self = self else { return }
            self.readItemLocal.updateReadItems(items).subscribe().disposed(by: self.disposeBag)
        }
        
        let remoteLoadAndUpdateLocal = self.readItemRemote
            .requestLoadMyItems(for: memberID)
            .do(onNext: updateLocal)
        
        return self.fetchMyItems().ignoreError().asObservable()
            .concat(remoteLoadAndUpdateLocal)
    }
    
    public func fetchCollectionItems(collectionID: String) -> Maybe<[ReadItem]> {
        return self.readItemLocal.fetchCollectionItems(collectionID)
    }
    
    public func requestLoadCollectionItems(collectionID: String) -> Observable<[ReadItem]> {
        
        let updateLocal: ([ReadItem]) -> Void = { [weak self] items in
            guard let self = self else { return }
            self.readItemLocal.updateReadItems(items).subscribe().disposed(by: self.disposeBag)
        }
        let remoteLoadAndUpdateLocal = self.readItemRemote.requestLoadCollectionItems(collectionID: collectionID)
            .do(onNext: updateLocal)
            
        return self.fetchCollectionItems(collectionID: collectionID).ignoreError().asObservable()
            .concat(remoteLoadAndUpdateLocal)
    }

    public func updateCollection(_ collection: ReadCollection) -> Maybe<Void> {
        return self.readItemLocal.updateReadItems([collection])
    }
    
    public func requestUpdateCollection(_ collection: ReadCollection) -> Maybe<Void> {
        
        let updateLocal: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.updateCollection(collection).subscribe().disposed(by: self.disposeBag)
        }
        return self.readItemRemote.requestUpdateReadCollection(collection)
            .do(onNext: updateLocal)
    }
    
    public func updateLink(_ link: ReadLink) -> Maybe<Void> {
        return self.readItemLocal.updateReadItems([link])
    }
    
    public func requestUpdateLink(_ link: ReadLink) -> Maybe<Void> {
        let updateLocal: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.updateLink(link).subscribe().disposed(by: self.disposeBag)
        }
        return self.readItemRemote.requestUpdateReadLink(link)
            .do(onNext: updateLocal)
    }
}
