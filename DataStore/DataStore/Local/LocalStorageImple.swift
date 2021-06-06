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

typealias FakeStore = UserDefaults

public final class LocalStorageImple: LocalStorage {
    
    public init() {}
    
    public func fetchCurrentAuth() -> Maybe<Auth?> {
        let userID = FakeStore.standard.string(forKey: "fake_uid")
        let auth = userID.map( Auth.init(userID:) )
        return .just(auth)
    }
    
    public func fetchCurrentMember() -> Maybe<Member?> {
        let userID = FakeStore.standard.string(forKey: "fake_uid")
        let member = userID.map { id -> Member in
            var member = Member(uid: id)
            member.nickName = FakeStore.standard.string(forKey: "fake_nick")
            member.introduction = FakeStore.standard.string(forKey: "fake_intro")
            if let icon = FakeStore.standard.string(forKey: "fake_icon") {
                member.icon = .path(icon)
            } else if let emoji = FakeStore.standard.string(forKey: "fake_emoji") {
                member.icon = .emoji(emoji)
            }
            return member
        }
        return .just(member)
    }
    
    public func saveSignedIn(auth: Auth) -> Maybe<Void> {
        FakeStore.standard.setValue(auth.userID, forKey: "fake_uid")
        return .just()
    }
    
    public func saveSignedIn(member: Member) -> Maybe<Void> {
        FakeStore.standard.setValue(member.uid, forKey: "fake_uid")
        FakeStore.standard.setValue(member.nickName, forKey: "fake_nick")
        FakeStore.standard.setValue(member.introduction, forKey: "fake_intro")
        if case let .path(path) = member.icon {
            FakeStore.standard.setValue(path, forKey: "fake_icon")
        } else if case let .emoji(value) = member.icon {
            FakeStore.standard.setValue(value, forKey: "fake_emoji")
        } else {
            FakeStore.standard.setValue(nil, forKey: "fake_icon")
            FakeStore.standard.setValue(nil, forKey: "fake_emoji")
        }
        return .just()
    }
    
    public func updateCurrentMember(_ newValue: Member) -> Maybe<Void> {
        FakeStore.standard.setValue(newValue.uid, forKey: "fake_uid")
        FakeStore.standard.setValue(newValue.nickName, forKey: "fake_nick")
        FakeStore.standard.setValue(newValue.introduction, forKey: "fake_intro")
        if case let .path(path) = newValue.icon {
            FakeStore.standard.setValue(path, forKey: "fake_icon")
        } else if case let .emoji(value) = newValue.icon {
            FakeStore.standard.setValue(value, forKey: "fake_emoji")
        } else {
            FakeStore.standard.setValue(nil, forKey: "fake_icon")
            FakeStore.standard.setValue(nil, forKey: "fake_emoji")
        }
        return .just()
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
        return .just(nil)
    }
    
    public func fetchHoorays(for memberID: String, limit: Int) -> Maybe<[Hooray]> {
        return .empty()
    }
    
    public func saveHoorays(_ hooray: [Hooray]) -> Maybe<Void> {
        return .empty()
    }
}
