//
//  LocalStorageImple+ItemCategory.swift
//  DataStore
//
//  Created by sudo.park on 2021/10/09.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


extension LocalStorageImple {
    
    public func fetchCategories(_ ids: [String]) -> Maybe<[ItemCategory]> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.fetchCategories(ids)
    }
    
    public func updateCategories(_ categories: [ItemCategory]) -> Maybe<Void> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.updateCategories(categories)
    }
    
    public func suggestCategories(_ name: String) -> Maybe<[SuggestCategory]> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.fetchingItemCategories(like: name)
            .map { $0.map { .init(ownerID: nil, category: $0, lastUpdated: 0) } }
    }
    
    public func loadLatestCategories() -> Maybe<[SuggestCategory]> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.fetchLatestItemCategories()
            .map { $0.map { .init(ownerID: nil, category: $0, lastUpdated: 0) } }
    }
    
    public func fetchCategories(earilerThan creatTime: TimeStamp,
                                pageSize: Int) -> Maybe<[ItemCategory]> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        
        return storage.fetchCategories(earilerThan: creatTime, pageSize: pageSize)
    }
    
    public func deleteCategory(_ itemID: String) -> Maybe<Void> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        
        return storage.deleteCategory(itemID)
    }
}

