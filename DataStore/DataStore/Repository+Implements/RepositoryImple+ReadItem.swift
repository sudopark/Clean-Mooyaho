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
    
    public func requestLoadMyItems(for memberID: String?) -> Observable<[ReadItem]> {
        
        let itemsOnLocal = self.readItemLocal.fetchMyItems(memberID: memberID)
        
        let updateLocal: ([ReadItem]) -> Void = { [weak self] items in
            guard let self = self else { return }
            self.readItemLocal.updateReadItems(items).subscribe().disposed(by: self.disposeBag)
        }
        let itemsOnRemote = memberID
            .map { self.readItemRemote.requestLoadMyItems(for: $0) } ?? .empty()
            .do(onNext: updateLocal)
        
        return itemsOnLocal.catchAndReturn([]).asObservable()
            .concat(itemsOnRemote)
        
    }
    
    public func requestLoadCollectionItems(collectionID: String) -> Observable<[ReadItem]> {
        
        let itemsOnLocal = self.readItemLocal.fetchCollectionItems(collectionID)
        
        let updateLocal: ([ReadItem]) -> Void = { [weak self] items in
            guard let self = self else { return }
            self.readItemLocal.updateReadItems(items).subscribe().disposed(by: self.disposeBag)
        }
        let itemsOnRemote = self.readItemRemote
            .requestLoadCollectionItems(collectionID: collectionID)
            .do(onNext: updateLocal)
            
        return itemsOnLocal.catchAndReturn([]).asObservable()
            .concat(itemsOnRemote)
    }

    public func requestUpdateCollection(_ collection: ReadCollection) -> Maybe<Void> {

        let updateOnLocal = { [weak self] in self?.readItemLocal.updateReadItems([collection]) ?? .empty() }
        let updateOnRemote = self.readItemRemote.requestUpdateReadCollection(collection)
        return updateOnRemote.switchOr(append: updateOnLocal, witoutError: ())
    }
    
    public func requestUpdateLink(_ link: ReadLink) -> Maybe<Void> {
        let updateOnLocal = { [weak self] in self?.readItemLocal.updateReadItems([link]) ?? .empty() }
        let updateOnRemote = self.readItemRemote.requestUpdateReadLink(link)
        return updateOnRemote.switchOr(append: updateOnLocal, witoutError: ())
    }
   
    public func requestLoadCollection(_ collectionID: String) -> Observable<ReadCollection> {
        
        let thenUdateLocal: (ReadCollection) -> Void = { [weak self] collection in
            guard let self = self else { return }
            self.readItemLocal.updateReadItems([collection])
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        let collectionOnLocal = self.readItemLocal.fetchCollection(collectionID)
        
        let collectionOnRemote = self.readItemRemote
            .requestLoadCollection(collectionID: collectionID)
            .do(onNext: thenUdateLocal)
                
        return collectionOnLocal.catchAndReturn(nil).compactMap { $0 }.asObservable()
            .concat(collectionOnRemote)
    }
}
