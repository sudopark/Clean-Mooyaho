//
//  LocalStorageImple+Search.swift
//  DataStore
//
//  Created by sudo.park on 2021/11/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


extension LocalStorageImple {
    
    public func fetchLatestSearchedQueries() -> Maybe<[LatestSearchedQuery]> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.fetchLatestSearchQueries()
    }
    
    public func insertLatestSearchQuery(_ query: String) -> Maybe<Void> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.insertLatestSearchQuery(query)
    }
    
    public func removeLatestSearchQuery(_ query: String) -> Maybe<Void> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.removeLatestSearchQuery(query)
    }
    
    public func fetchAllSuggestableQueries() -> Maybe<[String]> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.fetchAllSuggestableQueries()
    }
    
    public func insertSuggestableQueries(_ queries: [String]) -> Maybe<Void> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.insertSuggestableQueries(queries)
    }
}
