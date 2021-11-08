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
        guard let memberID = memberID else {
            return itemsOnLocal.asObservable()
        }
        
        let updateLocal: ([ReadItem]) -> Void = { [weak self] items in
            guard let self = self else { return }
            self.readItemLocal.updateReadItems(items).subscribe().disposed(by: self.disposeBag)
        }

        let itemsOnRemote = self.readItemRemote.requestLoadMyItems(for: memberID)
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
    
    public func requestUpdateItem(_ params: ReadItemUpdateParams) -> Maybe<Void> {
        let updateOnRemote = self.readItemRemote.requestUpdateItem(params)
        let updateOnLocal = { [weak self] in self?.readItemLocal.updateItem(params) ?? .empty() }
        return updateOnRemote.switchOr(append: updateOnLocal, witoutError: ())
    }
    
    public func requestFindLinkItem(using url: String) -> Maybe<ReadLink?> {
        
        let findInLocalWithoutError = self.readItemLocal.findLinkItem(using: url)
            .catchAndReturn(nil)
        
        let orFindInRemoteIfNotExistsOnLocal: (ReadLink?) -> Maybe<ReadLink?>
        orFindInRemoteIfNotExistsOnLocal = { [weak self] link in
            guard let self = self else { return .empty() }
            return link.map { .just($0) } ?? self.findLikItemInRemote(url)
        }
        
        return findInLocalWithoutError
            .flatMap(orFindInRemoteIfNotExistsOnLocal)
    }
    
    private func findLikItemInRemote(_ url: String) -> Maybe<ReadLink?> {
        
        let updateLocalIfPossible: (ReadLink?) -> Void = { [weak self] link in
            guard let self = self, let link = link else { return }
            self.readItemLocal.updateReadItems([link])
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        return self.readItemRemote.requestFindLinkItem(using: url)
            .do(onNext: updateLocalIfPossible)
    }
    
}
