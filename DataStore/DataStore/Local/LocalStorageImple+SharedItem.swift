//
//  LocalStorageImple+SharedItem.swift
//  DataStore
//
//  Created by sudo.park on 2021/11/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


extension LocalStorageImple {
    
    public func fetchLatestSharedCollections() -> Maybe<[SharedReadCollection]> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.fetchLatestSharedCollections()
    }
    
    public func replaceLastSharedCollections(_ collections: [SharedReadCollection]) -> Maybe<Void> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.replaceLastSharedCollections(collections)
    }
    
    public func saveSharedCollection(_ collection: SharedReadCollection) -> Maybe<Void> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.saveSharedCollection(collection)
    }
    
    public func fetchMySharingItemIDs() -> Maybe<[String]> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.fetchMySharingItemIDs()
    }
    
    public func updateMySharingItemIDs(_ ids: [String]) -> Maybe<Void> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.updateMySharingItemIDs(ids)
    }
}
