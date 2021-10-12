//
//  ReadItemOptionRemote+Firebase.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/10/13.
//

import Foundation

import RxSwift

import Domain
import DataStore


extension FirebaseServiceImple {
    
    public func requestLoadReadItemCustomOrder(for collectionID: String) -> Maybe<[String]?> {
        guard let _ = self.signInMemberID else {
            return .empty()
        }
        return .error(RemoteErrors.notFound("not implemented", reason: nil))
    }
    
    public func requestUpdateReadItemCustomOrder(for collection: String, itemIDs: [String]) -> Maybe<Void> {
        guard let _ = self.signInMemberID else {
            return .empty()
        }
        return .error(RemoteErrors.notFound("not implemented", reason: nil))
    }
}
