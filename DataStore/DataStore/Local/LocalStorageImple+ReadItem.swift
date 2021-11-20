//
//  LocalStorageImple+ReadItem.swift
//  DataStore
//
//  Created by sudo.park on 2021/09/16.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


extension LocalStorageImple {
    
    public func fetchMyItems(memberID: String?) -> Maybe<[ReadItem]> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.fetchMyReadItems()
    }
    
    public func fetchCollectionItems(_ collecitonID: String) -> Maybe<[ReadItem]> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.fetchReadCollectionItems(collecitonID)
    }
    
    public func updateReadItems(_ items: [ReadItem]) -> Maybe<Void> {
        
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        
        let collections = items.compactMap{ $0 as? ReadCollection }
        let links = items.compactMap{ $0 as? ReadLink }
        let updateCollectionsWithoutError = storage
            .updateReadCollections(collections).catchAndReturn(())
        
        let thenUpdateLinksWithoutError: () -> Maybe<Void> = { [weak self] in
            guard let storage = self?.dataModelStorage
            else {
                return .error(LocalErrors.localStorageNotReady)
            }
            return storage.updateReadLinks(links).catchAndReturn(())
        }
        return updateCollectionsWithoutError
            .flatMap(thenUpdateLinksWithoutError)
    }
    
    public func fetchCollection(_ collectionID: String) -> Maybe<ReadCollection?> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.fetchCollection(collectionID)
    }
    
    public func updateItem(_ params: ReadItemUpdateParams) -> Maybe<Void> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.updateItem(params)
    }
    
    public func findLinkItem(using url: String) -> Maybe<ReadLink?> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.findLinkItem(using: url)
    }
    
    public func removeItem(_ item: ReadItem) -> Maybe<Void> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.removeReadItem(item)
    }
}
