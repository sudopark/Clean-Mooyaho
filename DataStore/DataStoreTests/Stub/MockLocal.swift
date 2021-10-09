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
    
    func fetchMyItems() -> Maybe<[ReadItem]> {
        return self.resolve(key: "fetchMyItems") ?? .empty()
    }
    
    func fetchCollectionItems(_ collecitonID: String) -> Maybe<[ReadItem]> {
        return self.resolve(key: "fetchCollectionItems") ?? .empty()
    }
    
     func updateReadItems(_ items: [ReadItem]) -> Maybe<Void> {
        self.verify(key: "updateReadItems")
        return self.resolve(key: "updateReadItems") ?? .empty()
    }
    
    func fetchReadItemIsShrinkMode() -> Maybe<Bool> {
        return self.resolve(key: "fetchReadItemIsShrinkMode") ?? .empty()
    }
    
    func updateReadItemIsShrinkMode(_ newValue: Bool) -> Maybe<Void> {
        return self.resolve(key: "updateReadItemIsShrinkMode") ?? .empty()
    }
    
    func fetchReadItemSortOrder(for collectionID: String) -> Maybe<ReadCollectionItemSortOrder?> {
        return self.resolve(key: "fetchReadItemSortOrder") ?? .empty()
    }
    
    func updateReadItemSortOrder(for collectionID: String, to newValue: ReadCollectionItemSortOrder) -> Maybe<Void> {
        return self.resolve(key: "updateFetchReadItemSortOrder") ?? .empty()
    }
    
    func fetchReadItemCustomOrder(for collectionID: String) -> Maybe<[String]> {
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
}

