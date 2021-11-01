//
//  ItemCategoryRemote+Firebase.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/10/10.
//

import Foundation

import RxSwift

import Domain
import DataStore


extension FirebaseServiceImple {
    
    public func requestUpdateCategories(_ categories: [ItemCategory]) -> Maybe<Void> {
        guard let _ = self.signInMemberID else {
            return .empty()
        }
        return .error(RemoteErrors.notFound("not implemented", reason: nil))
    }
    
    public func requestLoadCategories(_ ids: [String]) -> Maybe<[ItemCategory]> {
        guard let _ = self.signInMemberID else {
            return .empty()
        }
        return .error(RemoteErrors.notFound("not implemented", reason: nil))
    }
    
    public func requestSuggestCategories(_ name: String,
                                         cursor: String?) -> Maybe<SuggestCategoryCollection> {
        guard let _ = self.signInMemberID else {
            return .empty()
        }
        return .error(RemoteErrors.notFound("not implemented", reason: nil))
    }
    
    public func requestLoadLastestCategories() -> Maybe<[SuggestCategory]> {
        guard let _ = self.signInMemberID else {
            return .empty()
        }
        return .error(RemoteErrors.notFound("not implemented", reason: nil))
    }
}
