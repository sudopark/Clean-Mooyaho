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
    
    func fetchRegisterPendingNewPlaceForm() -> Maybe<PendingRegisterNewPlaceForm?> {
        return self.resolve(key: "fetchRegisterPendingNewPlaceForm") ?? .empty()
    }
    
    func savePendingRegister(newPlace form: NewPlaceForm) -> Maybe<Void> {
        return self.resolve(key: "savePendingRegister") ?? .empty()
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
