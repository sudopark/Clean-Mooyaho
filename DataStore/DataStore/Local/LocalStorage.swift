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
    case notExists
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
    
    func fetchMembers(_ ids: [String]) -> Maybe<[Member]>
    
    func saveMembers(_ members: [Member]) -> Maybe<Void>
}

public protocol TagLocalStorage {
    
    func fetchRecentSelectTags(_ type: Tag.TagType, query: String) -> Maybe<[Tag]>
    
    func updateRecentSelect(tag: Tag) -> Maybe<Void>
    
    func removeRecentSelect(tag: Tag) -> Maybe<Void>
    
    func saveTags(_ tag: [Tag]) -> Maybe<Void>
}


public protocol PlaceLocalStorage {
    
    func fetchRegisterPendingNewPlaceForm(_ memberID: String) -> Maybe<PendingRegisterNewPlaceForm?>
    
    func savePendingRegister(newPlace form: NewPlaceForm) -> Maybe<Void>
    
    func removePendingRegisterForm(_ memberID: String) -> Maybe<Void>
    
    func savePlace(_ place: Place) -> Maybe<Void>
    
    func fetchPlace(_ placeID: String) -> Maybe<Place?>
}


public protocol HoorayLocalStorage {

    func fetchLatestHoorays(for memberID: String, limit: Int) -> Maybe<[Hooray]>
    
    func saveHoorays(_ hoorays: [Hooray]) -> Maybe<Void>
    
    func fetchHoorays(_ ids: [String]) -> Maybe<[Hooray]>
    
    func saveHoorayDetail(_ detail: HoorayDetail) -> Maybe<Void>
    
    func fetchHoorayDetail(_ id: String) -> Maybe<HoorayDetail?>
}

extension HoorayLocalStorage {
    
    public func saveHooray(_ hooray: Hooray) -> Maybe<Void> {
        return self.saveHoorays([hooray])
    }
    
    public func fetchHooray(_ id: String) -> Maybe<Hooray?> {
        return self.fetchHoorays([id]).map{ $0.first }
    }
    
    public func fetchLatestHooray(for memberID: String) -> Maybe<Hooray?> {
        return self.fetchLatestHoorays(for: memberID, limit: 1).map{ $0.first }
    }
}


public protocol ReadItemLocalStorage {
    
    func fetchMyItems() -> Maybe<[ReadItem]>
    
    func fetchCollectionItems(_ collecitonID: String) -> Maybe<[ReadItem]>
    
    func updateReadItems(_ items: [ReadItem]) -> Maybe<Void>
    
    func fetchCollection(_ collectionID: String) -> Maybe<ReadCollection?>
}


public protocol ReadItemOptionsLocalStorage {
    
    func fetchReadItemIsShrinkMode() -> Maybe<Bool>
    
    func updateReadItemIsShrinkMode(_ newValue: Bool) -> Maybe<Void>
    
    func fetchReadItemSortOrder(for collectionID: String) -> Maybe<ReadCollectionItemSortOrder?>
    
    func updateReadItemSortOrder(for collectionID: String,
                                 to newValue: ReadCollectionItemSortOrder) -> Maybe<Void>
    
    func fetchReadItemCustomOrder(for collectionID: String) -> Maybe<[String]>
    
    func updateReadItemCustomOrder(for collectionID: String, itemIDs: [String]) -> Maybe<Void>
}


public protocol LinkPreviewCacheStorage {
    
    func fetchPreview(_ url: String) -> Maybe<LinkPreview?>
    
    func saveLinkPreview(for url: String, preview: LinkPreview) -> Maybe<Void>
}

// MARK: - LocalStorage

public protocol LocalStorage: AuthLocalStorage, MemberLocalStorage, TagLocalStorage, PlaceLocalStorage, HoorayLocalStorage, ReadItemLocalStorage, ReadItemOptionsLocalStorage, LinkPreviewCacheStorage { }


// MARK: - LocalStorageImple

public final class LocalStorageImple: LocalStorage {
    
    let encryptedStorage: EncryptedStorage
    let environmentStorage: EnvironmentStorage
    let dataModelStorage: DataModelStorage
    
    public init(encryptedStorage: EncryptedStorage,
                environmentStorage: EnvironmentStorage,
                dataModelStorage: DataModelStorage) {
        
        self.encryptedStorage = encryptedStorage
        self.environmentStorage = environmentStorage
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
