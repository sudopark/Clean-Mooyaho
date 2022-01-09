//
//  UserDataMigratableLocalStorage.swift
//  DataStore
//
//  Created by sudo.park on 2021/11/06.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


extension LocalStorageImple {
    
    public func fetchFromAnonymousStorage<T>(_ type: T.Type, size: Int) -> Maybe<[T]> {
        
        let openStorage = self.dataModelGateway.openedAnonymousStorage()
        return openStorage.flatMap { $0.fetch(T.self, with: size) }
    }
    
    public func removeFromAnonymousStorage<T>(_ type: T.Type, in ids: [String]) -> Maybe<Void> {
        let prepareStorage = self.dataModelGateway.openedAnonymousStorage()
        return prepareStorage.flatMap { $0.remove(T.self, in: ids) }
    }
    
    public func saveToUserStorage<T>(_ type: T.Type, _ models: [T]) -> Maybe<Void> {
        guard let currentStorage = self.dataModelGateway.curentStorage else {
            return .empty()
        }
        return currentStorage.save(T.self, models)
    }
}
