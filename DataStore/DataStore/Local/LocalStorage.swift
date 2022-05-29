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
    
    func removeUserStorage() -> Maybe<Void>
}

public protocol AuthLocalStorage {

    func fetchCurrentAuth() -> Maybe<Auth?>
    func fetchCurrentMember() -> Maybe<Member?>
    func saveSignedIn(auth: Auth) -> Maybe<Void>
    func saveSignedIn(member: Member) -> Maybe<Void>
    func clearUserEnvironment()
}

public protocol MemberLocalStorage {
    
    func saveMember(_ member: Member) -> Maybe<Void>
    
    func fetchMember(for memberID: String) -> Maybe<Member?>
    
    func updateCurrentMember(_ newValue: Member) -> Maybe<Void>
    
    func fetchMembers(_ ids: [String]) -> Maybe<[Member]>
    
    func saveMembers(_ members: [Member]) -> Maybe<Void>
}

public protocol ReadItemLocalStorage {
    
    func fetchMyItems(memberID: String?) -> Maybe<[ReadItem]>
    
    func overwriteMyItems(memberID: String?, items: [ReadItem]) -> Maybe<Void>
    
    func fetchCollectionItems(_ collecitonID: String) -> Maybe<[ReadItem]>
    
    func overwriteCollectionItems(_ collectionID: String, items: [ReadItem]) -> Maybe<Void>
    
    func updateReadItems(_ items: [ReadItem]) -> Maybe<Void>
    
    func fetchCollection(_ collectionID: String) -> Maybe<ReadCollection?>
    
    func fetchReadLink(_ linkID: String) -> Maybe<ReadLink?>
    
    func updateItem(_ params: ReadItemUpdateParams) -> Maybe<Void>
    
    func findLinkItem(using url: String) -> Maybe<ReadLink?>
    
    func removeItem(_ item: ReadItem) -> Maybe<Void>
    
    func searchReadItems(_ name: String) -> Maybe<[SearchReadItemIndex]>
    
    func suggestNextReadItems(size: Int) -> Maybe<[ReadItem]>
    
    func fetchMathingItems(_ ids: [String]) -> Maybe<[ReadItem]>
    
    func updateLinkItemIsReading(id: String, isReading: Bool)
    
    func readingLinkItemIDs() -> [String]
    
    func fetchFavoriteItemIDs() -> Maybe<[String]>
    
    func replaceFavoriteItemIDs(_ newValue: [String]) -> Maybe<Void>
    
    func toggleItemIsFavorite(_ id: String, isOn: Bool) -> Maybe<Void>
    
    func fetchReloadNeedCollectionIDs() -> [String]
    
    func updateIsReloadNeedCollectionIDs(_ newValue: [String])
}


public protocol ReadItemOptionsLocalStorage {
    
    func fetchReadItemIsShrinkMode() -> Maybe<Bool?>
    
    func updateReadItemIsShrinkMode(_ newValue: Bool) -> Maybe<Void>
    
    func fetchLatestReadItemSortOrder() -> Maybe<ReadCollectionItemSortOrder?>
    
    func updateLatestReadItemSortOrder(to newValue: ReadCollectionItemSortOrder) -> Maybe<Void>
    
    func fetchReadItemCustomOrder(for collectionID: String) -> Maybe<[String]?>
    
    func updateReadItemCustomOrder(for collectionID: String, itemIDs: [String]) -> Maybe<Void>
    
    func isAddItemGuideEverShown() -> Bool
    
    func markAsAddItemGuideShown()
    
    func didWelComeItemAdded() -> Bool
    
    func updateDidWelcomeItemAdded()
}

public protocol ReadingOptionLocalStorage {
    
    func fetchLastReadPosition(for itemID: String) -> Maybe<ReadPosition?>
    
    func updateLastReadPosition(for itemID: String, _ position: Double) -> Maybe<ReadPosition>
    
    func updateEnableLastReadPositionSaveOption(_ isOn: Bool)
    
    func isEnabledLastReadPositionSaveOption() -> Bool
}

public protocol LinkPreviewCacheStorage {
    
    func fetchPreview(_ url: String) -> Maybe<LinkPreview?>
    
    func saveLinkPreview(for url: String, preview: LinkPreview) -> Maybe<Void>
}

public protocol ItemCategoryLocalStorage {
    
    func fetchCategories(_ ids: [String]) -> Maybe<[ItemCategory]>
    
    func updateCategories(_ categories: [ItemCategory]) -> Maybe<Void>
    
    func updateCategory(by params: UpdateCategoryAttrParams) -> Maybe<Void>
    
    func suggestCategories(_ name: String) -> Maybe<[SuggestCategory]>
    
    func loadLatestCategories() -> Maybe<[SuggestCategory]>
    
    func fetchCategories(earilerThan creatTime: TimeStamp, pageSize: Int) -> Maybe<[ItemCategory]>
    
    func deleteCategory(_ itemID: String) -> Maybe<Void>
    
    func findCategory(by name: String) -> Maybe<ItemCategory?>
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

public protocol SearchLocalStorage {
    
    func fetchLatestSearchedQueries() -> Maybe<[LatestSearchedQuery]>
    
    func insertLatestSearchQuery(_ query: String) -> Maybe<Void>
    
    func removeLatestSearchQuery(_ query: String) -> Maybe<Void>
    
    func fetchAllSuggestableQueries() -> Maybe<[String]>
    
    func insertSuggestableQueries(_ queries: [String]) -> Maybe<Void>
}

// MARK: - LocalStorage

public protocol LocalStorage: DataModelStorageSwitchable, AuthLocalStorage, MemberLocalStorage, ReadItemLocalStorage, ReadItemOptionsLocalStorage, ReadingOptionLocalStorage, LinkPreviewCacheStorage, ItemCategoryLocalStorage, ReadLinkMemoLocalStorage, UserDataMigratableLocalStorage, ShareItemLocalStorage, SearchLocalStorage { }


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
    
    public func removeUserStorage() -> Maybe<Void> {
        return .just(self.dataModelGateway.removeUserStorage())
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
