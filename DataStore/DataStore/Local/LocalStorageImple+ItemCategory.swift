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
        return .empty()
    }
    
    public func loadLatestCategories() -> Maybe<[SuggestCategory]> {
        return .empty()
    }
}

