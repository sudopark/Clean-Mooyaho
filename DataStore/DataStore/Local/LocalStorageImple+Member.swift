//
//  LocalStorageImple+Member.swift
//  DataStore
//
//  Created by sudo.park on 2021/06/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


extension LocalStorageImple {
    
    public func saveMember(_ member: Member) -> Maybe<Void> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.save(member: member)
    }
    
    public func fetchMember(for memberID: String) -> Maybe<Member?> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.fetchMember(for: memberID)
    }
    
    public func updateCurrentMember(_ newValue: Member) -> Maybe<Void> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.updateMember(newValue)
    }
    
    public func fetchMembers(_ ids: [String]) -> Maybe<[Member]> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.fetchMembers(ids)
    }
    
    public func saveMembers(_ members: [Member]) -> Maybe<Void> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.insertOrUpdateMembers(members)
    }
}
