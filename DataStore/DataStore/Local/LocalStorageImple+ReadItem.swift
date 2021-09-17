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
    
    public func fetchMyItems() -> Maybe<[ReadItem]> {
        return .empty()
    }
    
    public func fetchCollectionItems(_ collecitonID: String) -> Maybe<[ReadItem]> {
        return .empty()
    }
    
    public func updateReadItems(_ items: [ReadItem]) -> Maybe<Void> {
        return .empty()
    }
}
