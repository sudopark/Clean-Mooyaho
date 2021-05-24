//
//  LocalStorageImple.swift
//  DataStore
//
//  Created by sudo.park on 2021/05/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


public final class LocalStorageImple: LocalStorage {
    
    public init() {}
    
    public func fetchCurrentAuth() -> Maybe<Auth?> {
        return .just(nil)
    }
    
    public func fetchCurrentMember() -> Maybe<Member?> {
        return .just(nil)
    }
    
    public func saveSignedIn(auth: Auth) -> Maybe<Void> {
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
    
    public func fetchRegisterPendingNewPlaceForm() -> Maybe<PendingRegisterNewPlaceForm?> {
        return .empty()
    }
    
    public func savePendingRegister(newPlace form: NewPlaceForm) -> Maybe<Void> {
        return .empty()
    }
    
    public func savePlaces(_ places: [Place]) -> Maybe<Void> {
        return .empty()
    }
    
    public func fetchLatestHooray(for memberID: String) -> Maybe<Hooray?> {
        return .empty()
    }
    
    public func fetchHoorays(for memberID: String, limit: Int) -> Maybe<[Hooray]> {
        return .empty()
    }
    
    public func saveHoorays(_ hooray: [Hooray]) -> Maybe<Void> {
        return .empty()
    }
}
