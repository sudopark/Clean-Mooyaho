//
//  LocalStorageImpleTag.swift
//  DataStore
//
//  Created by sudo.park on 2021/06/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


extension LocalStorageImple {
        
    public func fetchRecentSelectTags(_ type: Tag.TagType, query: String) -> Maybe<[Tag]> {
        return .empty()
    }
    
    public func updateRecentSelect(tag: Tag) -> Maybe<Void> {
        return .empty()
    }
    
    public func removeRecentSelect(tag: Tag) -> Maybe<Void> {
        return .empty()
    }
    
    public func saveTags(_ tag: [Tag]) -> Maybe<Void> {
        return .empty()
    }
}
