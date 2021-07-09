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


class StubLocal: LocalStorage, Stubbable {
    
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
    
    func fetchMember(for memberID: String) -> Maybe<Member?> {
        return self.resolve(key: "fetchMember") ?? .empty()
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
    
    func savePlaces(_ places: [Place]) -> Maybe<Void> {
        self.verify(key: "savePlaces")
        return self.resolve(key: "savePlaces") ?? .empty()
    }
    
    func fetchLatestHooray(for memberID: String) -> Maybe<Hooray?> {
        return self.resolve(key: "fetchLatestHooray") ?? .empty()
    }
    
    func fetchHoorays(for memberID: String, limit: Int) -> Maybe<[Hooray]> {
        return self.resolve(key: "fetchHoorays") ?? .empty()
    }
    
    func saveHoorays(_ hooray: [Hooray]) -> Maybe<Void> {
        self.verify(key: "saveHoorays")
        return self.resolve(key: "saveHoorays") ?? .empty()
    }
}
