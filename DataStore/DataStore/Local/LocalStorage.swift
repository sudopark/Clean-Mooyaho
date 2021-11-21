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
    case localStorageNotReady
}

public protocol DataModelStorageSwitchable {
    
    func openStorage(for auth: Auth) -> Maybe<Void>
    
    func switchToAnonymousStorage() -> Maybe<Void>
    
    func switchToUserStorage(_ userID: String) -> Maybe<Void>
    
    func checkHasAnonymousStorage() -> Bool
    
    func removeAnonymousStorage() -> Maybe<Void>
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
    
    func fetchMyItems(memberID: String?) -> Maybe<[ReadItem]>
    
    func fetchCollectionItems(_ collecitonID: String) -> Maybe<[ReadItem]>
    
    func updateReadItems(_ items: [ReadItem]) -> Maybe<Void>
    
    func fetchCollection(_ collectionID: String) -> Maybe<ReadCollection?>
    
    func updateItem(_ params: ReadItemUpdateParams) -> Maybe<Void>
    
    func findLinkItem(using url: String) -> Maybe<ReadLink?>
    
    func removeItem(_ item: ReadItem) -> Maybe<Void>
    
    func searchReadItems(_ name: String) -> Maybe<[SearchReadItemIndex]>
}


public protocol ReadItemOptionsLocalStorage {
    
    func fetchReadItemIsShrinkMode() -> Maybe<Bool?>
    
    func updateReadItemIsShrinkMode(_ newValue: Bool) -> Maybe<Void>
    
    func fetchLatestReadItemSortOrder() -> Maybe<ReadCollectionItemSortOrder?>
    
    func updateLatestReadItemSortOrder(to newValue: ReadCollectionItemSortOrder) -> Maybe<Void>
    
    func fetchReadItemCustomOrder(for collectionID: String) -> Maybe<[String]?>
    
    func updateReadItemCustomOrder(for collectionID: String, itemIDs: [String]) -> Maybe<Void>
}


public protocol LinkPreviewCacheStorage {
    
    func fetchPreview(_ url: String) -> Maybe<LinkPreview?>
    
    func saveLinkPreview(for url: String, preview: LinkPreview) -> Maybe<Void>
}

public protocol ItemCategoryLocalStorage {
    
    func fetchCategories(_ ids: [String]) -> Maybe<[ItemCategory]>
    
    func updateCategories(_ categories: [ItemCategory]) -> Maybe<Void>
    
    func suggestCategories(_ name: String) -> Maybe<[SuggestCategory]>
    
    func loadLatestCategories() -> Maybe<[SuggestCategory]>
}

public protocol ReadLinkMemoLocalStorage {
    
    func fetchMemo(for linkItemID: String) -> Maybe<ReadLinkMemo?>
    
    func updateMemo(_ newValue: ReadLinkMemo) -> Maybe<Void>
    
    func deleteMemo(for linkItemID: String) -> Maybe<Void>
}

public protocol UserDataMigratableLocalStorage {
    
    func fetchFromAnonymousStorage<T>(_ type: T.Type, size: Int) -> Maybe<[T]>
    func removeFromAnonymousStorage<T>(_ type: T.Type, in ids: [String]) -> Maybe<Void>
    func saveToUserStorage<T>(_ type: T.Type, _ models: [T]) -> Maybe<Void>
}

public protocol ShareItemLocalStorage {
    
    func fetchLatestSharedCollections() -> Maybe<[SharedReadCollection]>
    
    func replaceLastSharedCollections(_ collections: [SharedReadCollection]) -> Maybe<Void>
    
    func removeSharedCollection(shareID: String) -> Maybe<Void>
    
    func saveSharedCollection(_ collection: SharedReadCollection) -> Maybe<Void>
    
    func fetchMySharingItemIDs() -> Maybe<[String]>
    
    func updateMySharingItemIDs(_ ids: [String]) -> Maybe<Void>
}

// MARK: - LocalStorage

public protocol LocalStorage: DataModelStorageSwitchable, AuthLocalStorage, MemberLocalStorage, TagLocalStorage, PlaceLocalStorage, HoorayLocalStorage, ReadItemLocalStorage, ReadItemOptionsLocalStorage, LinkPreviewCacheStorage, ItemCategoryLocalStorage, ReadLinkMemoLocalStorage, UserDataMigratableLocalStorage, ShareItemLocalStorage { }


// MARK: - LocalStorageImple

public final class LocalStorageImple: LocalStorage {
    
    let encryptedStorage: EncryptedStorage
    let environmentStorage: EnvironmentStorage
    let dataModelGateway: DataModelStorageGateway
    
    var dataModelStorage: DataModelStorage? {
        return self.dataModelGateway.curentStorage
    }
    
    public init(encryptedStorage: EncryptedStorage,
                environmentStorage: EnvironmentStorage,
                dataModelGateway: DataModelStorageGateway) {
        
        self.encryptedStorage = encryptedStorage
        self.environmentStorage = environmentStorage
        self.dataModelGateway = dataModelGateway
    }
    
    public func openStorage(for auth: Auth) -> Maybe<Void> {
        return self.dataModelGateway.openUserStorage(auth.userID)
    }
    
    public func switchToAnonymousStorage() -> Maybe<Void> {
        return self.dataModelGateway.switchToAnonymousStorage()
    }
    
    public func switchToUserStorage(_ userID: String) -> Maybe<Void> {
        return self.dataModelGateway.switToUserStorage(userID)
    }
    
    public func checkHasAnonymousStorage() -> Bool {
        return self.dataModelGateway.checkHasAnonymousStorage()
    }
    
    public func removeAnonymousStorage() -> Maybe<Void> {
        return .just(self.dataModelGateway.removeAnonymousStorage())
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
