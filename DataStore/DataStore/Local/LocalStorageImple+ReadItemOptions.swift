//
//  LocalStorageImple+ReadItemOptions.swift
//  DataStore
//
//  Created by sudo.park on 2021/09/20.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


extension LocalStorageImple {
    
    public func fetchReadItemIsShrinkMode() -> Maybe<Bool> {
        return self.environmentStorage.fetchReadItemIsShrinkMode()
    }
    
    public func updateReadItemIsShrinkMode(_ newValue: Bool) -> Maybe<Void> {
        return self.environmentStorage.updateReadItemIsShrinkMode(newValue)
    }
    
    public func fetchReadItemSortOrder(for collectionID: String) -> Maybe<ReadCollectionItemSortOrder?> {
        return environmentStorage.fetchReadItemSortOrder(for: collectionID)
    }
    
    public func updateReadItemSortOrder(for collectionID: String,
                                             to newValue: ReadCollectionItemSortOrder) -> Maybe<Void> {
        return environmentStorage.updateReadItemSortOrder(for: collectionID, to: newValue)
    }
    
    public func fetchReadItemCustomOrder(for collectionID: String) -> Maybe<[String]> {
        return environmentStorage.fetchReadItemCustomOrder(for: collectionID)
    }
    
    public func updateReadItemCustomOrder(for collectionID: String, itemIDs: [String]) -> Maybe<Void> {
        return environmentStorage.updateReadItemCustomOrder(for: collectionID, itemIDs: itemIDs)
    }
}
