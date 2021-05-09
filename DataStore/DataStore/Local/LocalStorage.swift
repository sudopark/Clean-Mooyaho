//
//  Local.swift
//  DataStore
//
//  Created by ParkHyunsoo on 2021/04/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


public protocol LocalStorage: AuthLocalStorage, TagLocalStorage { }


public protocol AuthLocalStorage {

    func fetchCurrentMember() -> Maybe<Member?>
    func saveSignedIn(member: Member) -> Maybe<Void>
}

public protocol TagLocalStorage {
    
    func fetchRecentSelectTags(_ type: Tag.TagType, query: String) -> Maybe<[Tag]>
    
    func updateRecentSelect(tag: Tag) -> Maybe<Void>
    
    func removeRecentSelect(tag: Tag) -> Maybe<Void>
    
    func saveTags(_ tag: [Tag]) -> Maybe<Void>
}


public class FakeLocal: LocalStorage {
    
    public func fetchCurrentMember() -> Maybe<Member?> {
        return .empty()
    }
    
    public func saveSignedIn(member: Member) -> Maybe<Void> {
        return .empty()
    }
    
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
