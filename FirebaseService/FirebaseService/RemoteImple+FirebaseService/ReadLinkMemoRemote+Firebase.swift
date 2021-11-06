//
//  ReadLinkMemoRemote+Firebase.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/10/24.
//

import Foundation

import RxSwift

import Domain
import DataStore


extension FirebaseServiceImple {
    
    private typealias Key = ReadLinkMemoMappingKey
    
    public func requestLoadMemo(for linkItemID: String) -> Maybe<ReadLinkMemo?> {
        guard let memberID = self.signInMemberID else {
            return .empty()
        }
        let docuID = ReadLinkMemo.uuid(for: memberID, with: linkItemID)
        return self.load(docuID: docuID, in: .linkMemo)
    }
    
    public func requestUpdateMemo(_ newValue: ReadLinkMemo) -> Maybe<Void> {
        guard let _ = self.signInMemberID else {
            return .empty()
        }
        return self.save(newValue, at: .linkMemo, merging: true)
    }
    
    public func requestDeleteMemo(for linkItemID: String) -> Maybe<Void> {
        guard let memberID = self.signInMemberID else {
            return .empty()
        }
        let docuID = ReadLinkMemo.uuid(for: memberID, with: linkItemID)
        return self.delete(docuID, at: .linkMemo)
    }
}

private extension ReadLinkMemo {
    
    static func uuid(for ownerID: String, with itemID: String) -> String {
        return "\(itemID)-\(ownerID)"
    }
}
