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

public enum LocalErrors: Error {
    case invalidData(_ reason: String?)
    case deserializeFail(_ for: String?)
}


public protocol AuthLocalStorage {

    func fetchCurrentAuth() -> Maybe<Auth?>
    func fetchCurrentMember() -> Maybe<Member?>
    func saveSignedIn(auth: Auth) -> Maybe<Void>
    func saveSignedIn(member: Member) -> Maybe<Void>
}

public protocol MemberLocalStorage {
    
    func saveMember(_ member: Member) -> Maybe<Void>
    
    func fetchMember(for memberID: String) -> Maybe<Member?>
    
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
    
    let encryptedStorage: EncryptedStorage
    let dataModelStorage: DataModelStorage
    
    public init(encryptedStorage: EncryptedStorage,
                dataModelStorage: DataModelStorage) {
        
        self.encryptedStorage = encryptedStorage
        self.dataModelStorage = dataModelStorage
    }
}


// MARK: - helper extensions

extension Result where Failure == Error {
    
    func runMaybeCallback(_ callback: @escaping (MaybeEvent<Success>) -> Void) {
        switch self {
        case let .success(value):
            callback(.success(value))
            
        case let .failure(error):
            callback(.error(error))
        }
    }
}
