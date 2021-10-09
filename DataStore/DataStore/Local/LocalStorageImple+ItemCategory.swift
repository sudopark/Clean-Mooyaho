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
        return self.dataModelStorage.fetchCategories(ids)
    }
    
    public func updateCategories(_ categories: [ItemCategory]) -> Maybe<Void> {
        return self.dataModelStorage.updateCategories(categories)
    }
    
    public func suggestCategories(_ name: String) -> Maybe<[SuggestCategory]> {
        return self.dataModelStorage.fetchingItemCategories(like: name)
            .map { $0.map { .init(ownerID: nil, category: $0, lastUpdated: 0) } }
    }
    
    public func loadLatestCategories() -> Maybe<[SuggestCategory]> {
        return self.dataModelStorage.fetchLatestItemCategories()
            .map { $0.map { .init(ownerID: nil, category: $0, lastUpdated: 0) } }
    }
}

