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
    
    public func updateLastSharedCollections(_ collections: [SharedReadCollection]) -> Maybe<Void> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.updateLastSharedCollections(collections)
    }
}
