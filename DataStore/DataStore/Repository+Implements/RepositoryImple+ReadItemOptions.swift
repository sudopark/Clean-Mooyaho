//
//  RepositoryImple+ReadItemOptions.swift
//  DataStore
//
//  Created by sudo.park on 2021/09/20.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


public protocol ReadItemOptionReposiotryDefImpleDependency: AnyObject {
    
    var disposeBag: DisposeBag { get }
    var readItemOptionLocal: ReadItemOptionsLocalStorage {get }
}

extension ReadItemOptionsRepository where Self: ReadItemOptionReposiotryDefImpleDependency {
    
    public func fetchLastestsIsShrinkModeOn() -> Maybe<Bool> {
        return self.readItemOptionLocal.fetchReadItemIsShrinkMode()
    }
    
    public func updateIsShrinkModeOn(_ newvalue: Bool) -> Maybe<Void> {
        return self.readItemOptionLocal.updateReadItemIsShrinkMode(newvalue)
    }
    
    public func fetchSortOrder(for collectionID: String) -> Maybe<ReadCollectionItemSortOrder?> {
        return self.readItemOptionLocal.fetchReadItemSortOrder(for: collectionID)
    }
    
    public func fetchCustomSortOrder(for collectionID: String) -> Maybe<[String]> {
        return self.readItemOptionLocal.fetchReadItemCustomOrder(for: collectionID)
    }
    
    public func updateSortOrder(for collectionID: String,
                         to newValue: ReadCollectionItemSortOrder) -> Maybe<Void> {
        return self.readItemOptionLocal.updateReadItemSortOrder(for: collectionID, to: newValue)
    }
    
    public func updateCustomSortOrder(for collectionID: String, itemIDs: [String]) -> Maybe<Void> {
        return self.readItemOptionLocal.updateReadItemCustomOrder(for: collectionID, itemIDs: itemIDs)
    }
}
