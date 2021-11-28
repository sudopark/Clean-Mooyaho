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
    
    public func fetchReadLink(_ linkID: String) -> Maybe<ReadLink?> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.fetchReadLink(linkID)
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
    
    public func searchReadItems(_ name: String) -> Maybe<[SearchReadItemIndex]> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.fetchReadItem(like: name)
    }
    
    public func suggestNextReadItems(size: Int) -> Maybe<[ReadItem]> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return .empty()
    }
    
    public func fetchMathingItems(_ ids: [String]) -> Maybe<[ReadItem]> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return .empty()
    }
    
    public func updateLinkItemIsReading(id: String, isReading: Bool) {
        
    }
    
    public func readingLinkItemIDs() -> [String] {
        return []
    }
    
    public func fetchFavoriteItemIDs() -> Maybe<[String]> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return .empty()
    }
    
    public func replaceFavoriteItemIDs(_ newValue: [String]) -> Maybe<Void> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return .empty()
    }
    
    public func toggleItemIsFavorite(_ id: String, isOn: Bool) -> Maybe<Void> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return .empty()
    }
}
