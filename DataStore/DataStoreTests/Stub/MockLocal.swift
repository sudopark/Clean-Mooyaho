//
//  StubLocal.swift
//  DataStoreTests
//
//  Created by ParkHyunsoo on 2021/05/02.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import UnitTestHelpKit
import Domain

@testable import DataStore


class MockLocal: LocalStorage, Mocking {
    
    func checkHasAnonymousStorage() -> Bool {
        return self.resolve(key: "checkHasAnonymousStorage") ?? false
    }
    
    func openStorage(for auth: Auth) -> Maybe<Void> {
        self.verify(key: "openStorage-\(auth.userID)")
        return .just()
    }
    
    var didSwitchToAnonymousStorage = false
    func switchToAnonymousStorage() -> Maybe<Void> {
        self.didSwitchToAnonymousStorage = true
        return .just()
    }
    
    func switchToUserStorage(_ userID: String) -> Maybe<Void> {
        self.verify(key: "switchToUserStorage", with: userID)
        return .just()
    }
    
    func fetchCurrentAuth() -> Maybe<Auth?> {
        return self.resolve(key: "fetchCurrentAuth") ?? .empty()
    }
    
    func saveSignedIn(auth: Auth) -> Maybe<Void> {
        return self.resolve(key: "saveSignedIn") ?? .empty()
    }
    
    func fetchCurrentMember() -> Maybe<Member?> {
        return self.resolve(key: "fetchCurrentMember") ?? .empty()
    }
    
    func saveSignedIn(member: Member) -> Maybe<Void> {
        self.verify(key: "saveSignedIn:member", with: member)
        return self.resolve(key: "saveSignedIn:member") ?? .empty()
    }
    
    func saveMember(_ member: Member) -> Maybe<Void> {
        return self.resolve(key: "saveMember") ?? .empty()
    }
    
    func saveMembers(_ members: [Member]) -> Maybe<Void> {
        return self.resolve(key: "saveMembers") ?? .empty()
    }
    
    func fetchMember(for memberID: String) -> Maybe<Member?> {
        return self.resolve(key: "fetchMember") ?? .empty()
    }
    
    func fetchMembers(_ ids: [String]) -> Maybe<[Member]> {
        return self.resolve(key: "fetchMembers") ?? .empty()
    }
    
    func updateCurrentMember(_ newValue: Member) -> Maybe<Void> {
        self.verify(key: "updateCurrentMember")
        return self.resolve(key: "updateCurrentMember") ?? .empty()
    }
    
    func fetchRecentSelectTags(_ type: Tag.TagType, query: String) -> Maybe<[Tag]> {
        return self.resolve(key: "fetchRecentSelectTags") ?? .empty()
    }
    
    func updateRecentSelect(tag: Tag) -> Maybe<Void> {
        self.verify(key: "updateRecentSelect")
        return self.resolve(key: "updateRecentSelect") ?? .empty()
    }
    
    func removeRecentSelect(tag: Tag) -> Maybe<Void> {
        return self.resolve(key: "removeRecentSelect") ?? .empty()
    }
    
    func saveTags(_ tag: [Tag]) -> Maybe<Void> {
        self.verify(key: "saveTags")
        return .just()
    }
    
    func fetchRegisterPendingNewPlaceForm(_ memberID: String) -> Maybe<PendingRegisterNewPlaceForm?> {
        return self.resolve(key: "fetchRegisterPendingNewPlaceForm") ?? .empty()
    }
    
    func savePendingRegister(newPlace form: NewPlaceForm) -> Maybe<Void> {
        return self.resolve(key: "savePendingRegister") ?? .empty()
    }
    
    func removePendingRegisterForm(_ memberID: String) -> Maybe<Void> {
        self.verify(key: "removePendingRegisterForm")
        return self.resolve(key: "removePendingRegisterForm") ?? .empty()
    }
    
    func savePlace(_ place: Place) -> Maybe<Void> {
        self.verify(key: "savePlaces")
        return self.resolve(key: "savePlaces") ?? .empty()
    }
    
    func fetchPlace(_ placeID: String) -> Maybe<Place?> {
        return self.resolve(key: "fetchPlace") ?? .empty()
    }
    
    func fetchLatestHoorays(for memberID: String, limit: Int) -> Maybe<[Hooray]> {
        return self.resolve(key: "fetchLatestHoorays") ?? .empty()
    }
    
    func saveHoorays(_ hooray: [Hooray]) -> Maybe<Void> {
        self.verify(key: "saveHoorays")
        return self.resolve(key: "saveHoorays") ?? .empty()
    }
    
    func fetchHoorays(_ ids: [String]) -> Maybe<[Hooray]> {
        return self.resolve(key: "fetchHoorays") ?? .empty()
    }
    
    func saveHoorayDetail(_ detail: HoorayDetail) -> Maybe<Void> {
        self.verify(key: "saveHoorayDetail")
        return self.resolve(key: "saveHoorayDetail") ?? .empty()
    }
    
    func fetchHoorayDetail(_ id: String) -> Maybe<HoorayDetail?> {
        return self.resolve(key: "fetchHoorayDetail") ?? .empty()
    }
    
    func fetchMyItems(memberID: String?) -> Maybe<[ReadItem]> {
        return self.resolve(key: "fetchMyItems") ?? .empty()
    }
    
    func fetchCollectionItems(_ collecitonID: String) -> Maybe<[ReadItem]> {
        return self.resolve(key: "fetchCollectionItems") ?? .empty()
    }
    
     func updateReadItems(_ items: [ReadItem]) -> Maybe<Void> {
        self.verify(key: "updateReadItems")
        return self.resolve(key: "updateReadItems") ?? .empty()
    }
    
    func updateItem(_ params: ReadItemUpdateParams) -> Maybe<Void> {
        self.verify(key: "updateItem")
        return self.resolve(key: "updateItem") ?? .empty()
    }
    
    func findLinkItem(using url: String) -> Maybe<ReadLink?> {
        return self.resolve(key: "findLinkItem") ?? .empty()
    }
    
    func removeItem(_ item: ReadItem) -> Maybe<Void> {
        return self.resolve(key: "removeItem") ?? .empty()
    }
    
    func searchReadItems(_ name: String) -> Maybe<[SearchReadItemIndex]> {
        return self.resolve(key: "suggestReadItems") ?? .empty()
    }
    
    func fetchReadItemIsShrinkMode() -> Maybe<Bool?> {
        return self.resolve(key: "fetchReadItemIsShrinkMode") ?? .empty()
    }
    
    func updateReadItemIsShrinkMode(_ newValue: Bool) -> Maybe<Void> {
        return self.resolve(key: "updateReadItemIsShrinkMode") ?? .empty()
    }
    
    func fetchLatestReadItemSortOrder() -> Maybe<ReadCollectionItemSortOrder?> {
        return self.resolve(key: "fetchLatestReadItemSortOrder") ?? .empty()
    }
    
    func updateLatestReadItemSortOrder(to newValue: ReadCollectionItemSortOrder) -> Maybe<Void> {
        return self.resolve(key: "updateLatestReadItemSortOrder") ?? .empty()
    }
    
    func fetchReadItemCustomOrder(for collectionID: String) -> Maybe<[String]?> {
        return self.resolve(key: "fetchReadItemCustomOrder") ?? .empty()
    }
    
    func updateReadItemCustomOrder(for collectionID: String, itemIDs: [String]) -> Maybe<Void> {
        return self.resolve(key: "updateReadItemCustomOrder") ?? .empty()
    }
    
    func fetchPreview(_ url: String) -> Maybe<LinkPreview?> {
        return self.resolve(key: "fetchPreview") ?? .empty()
    }
    
    func saveLinkPreview(for url: String, preview: LinkPreview) -> Maybe<Void> {
        self.verify(key: "saveLinkPreview", with: preview)
        return self.resolve(key: "saveLinkPreview") ?? .empty()
    }
    
    func fetchCollection(_ collectionID: String) -> Maybe<ReadCollection?> {
        return self.resolve(key: "fetchCollection") ?? .empty()
    }
    
    func fetchCategories(_ ids: [String]) -> Maybe<[ItemCategory]> {
        return self.resolve(key: "fetchCategories") ?? .empty()
    }
    
    func updateCategories(_ categories: [ItemCategory]) -> Maybe<Void> {
        return self.resolve(key: "updateCategories") ?? .empty()
    }
    
    func suggestCategories(_ name: String) -> Maybe<[SuggestCategory]> {
        return self.resolve(key: "suggestCategories") ?? .empty()
    }
    
    func loadLatestCategories() -> Maybe<[SuggestCategory]> {
        return self.resolve(key: "loadLatestCategories") ?? .empty()
    }
    
    func fetchMemo(for linkItemID: String) -> Maybe<ReadLinkMemo?> {
        return self.resolve(key: "fetchMemo") ?? .empty()
    }
    
    func updateMemo(_ newValue: ReadLinkMemo) -> Maybe<Void> {
        return self.resolve(key: "updateMemo") ?? .empty()
    }
    
    func deleteMemo(for linkItemID: String) -> Maybe<Void> {
        return self.resolve(key: "deleteMemo") ?? .empty()
    }
    
    func fetchFromAnonymousStorage<T>(_ type: T.Type, size: Int) -> Maybe<[T]> {
        return self.resolve(key: "fetchFromAnonymousStorage") ?? .empty()
    }
    
    func removeFromAnonymousStorage<T>(_ type: T.Type, in ids: [String]) -> Maybe<Void> {
        return self.resolve(key: "removeFromAnonymousStorage") ?? .empty()
    }
    
    func saveToUserStorage<T>(_ type: T.Type, _ models: [T]) -> Maybe<Void> {
        return self.resolve(key: "saveToUserStorage") ?? .empty()
    }
    
    func removeAnonymousStorage() -> Maybe<Void> {
        return self.resolve(key: "removeAnonymousStorage") ?? .empty()
    }
    
    func fetchLatestSharedCollections() -> Maybe<[SharedReadCollection]> {
        return self.resolve(key: "fetchLatestSharedCollections") ?? .empty()
    }
    
    func replaceLastSharedCollections(_ collections: [SharedReadCollection]) -> Maybe<Void> {
        self.verify(key: "replaceLastSharedCollections", with: collections)
        return self.resolve(key: "replaceLastSharedCollections") ?? .empty()
    }
    
    func saveSharedCollection(_ collection: SharedReadCollection) -> Maybe<Void> {
        self.verify(key: "saveSharedCollection", with: collection)
        return self.resolve(key: "saveSharedCollection") ?? .empty()
    }
    
    func fetchMySharingItemIDs() -> Maybe<[String]> {
        return self.resolve(key: "fetchMySharingItemIDs") ?? .empty()
    }
    
    func updateMySharingItemIDs(_ ids: [String]) -> Maybe<Void> {
        self.verify(key: "updateMySharingItemIDs", with: ids)
        return .just()
    }
    
    func removeSharedCollection(shareID: String) -> Maybe<Void> {
        self.verify(key: "removeSharedCollection")
        return .just()
    }
}

