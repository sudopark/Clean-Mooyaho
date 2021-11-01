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
    
    public func requestLoadMemo(for linkItemID: String) -> Maybe<ReadLinkMemo?> {
        guard let _ = self.signInMemberID else {
            return .empty()
        }
        return .error(RemoteErrors.notFound("not implemented", reason: nil))
    }
    
    public func requestUpdateMemo(_ newValue: ReadLinkMemo) -> Maybe<Void> {
        guard let _ = self.signInMemberID else {
            return .empty()
        }
        return .error(RemoteErrors.notFound("not implemented", reason: nil))
    }
    
    public func requestDeleteMemo(for linkItemID: String) -> Maybe<Void> {
        guard let _ = self.signInMemberID else {
            return .empty()
        }
        return .error(RemoteErrors.notFound("not implemented", reason: nil))
    }
}

