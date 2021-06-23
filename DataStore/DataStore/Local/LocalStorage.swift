//
//  Local.swift
//  DataStore
//
//  Created by ParkHyunsoo on 2021/04/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import SQLiteStorage

import Domain

public enum LocalErrors: Error {
    case invalidData(_ reason: String?)
}


public protocol AuthLocalStorage {

    func fetchCurrentAuth() -> Maybe<Auth?>
    func fetchCurrentMember() -> Maybe<Member?>
    func saveSignedIn(auth: Auth) -> Maybe<Void>
    func saveSignedIn(member: Member) -> Maybe<Void>
}

public protocol MemberLocalStorage {
    
    func updateCurrentMember(_ newValue: Member) -> Maybe<Void>
}

public protocol TagLocalStorage {
    
    func fetchRecentSelectTags(_ type: Tag.TagType, query: String) -> Maybe<[Tag]>
    
    func updateRecentSelect(tag: Tag) -> Maybe<Void>
    
    func removeRecentSelect(tag: Tag) -> Maybe<Void>
    
    func saveTags(_ tag: [Tag]) -> Maybe<Void>
}


public protocol PlaceLocalStorage {
    
    func fetchRegisterPendingNewPlaceForm() -> Maybe<PendingRegisterNewPlaceForm?>
    
    func savePendingRegister(newPlace form: NewPlaceForm) -> Maybe<Void>
    
    func removePendingRegisterForm() -> Maybe<Void>
    
    func savePlaces(_ places: [Place]) -> Maybe<Void>
}


public protocol HoorayLocalStorage {

    func fetchLatestHooray(for memberID: String) -> Maybe<Hooray?>
    
    func fetchHoorays(for memberID: String, limit: Int) -> Maybe<[Hooray]>
    
    func saveHoorays(_ hooray: [Hooray]) -> Maybe<Void>
}


// MARK: - LocalStorage

public protocol LocalStorage: AuthLocalStorage, MemberLocalStorage, TagLocalStorage, PlaceLocalStorage, HoorayLocalStorage { }


// MARK: - LocalStorageImple

public final class LocalStorageImple: LocalStorage {
    
    let sqliteStorage: SQLiteStorage
    
    public init(sqlite: SQLiteStorage) {
        self.sqliteStorage = sqlite
    }
}
