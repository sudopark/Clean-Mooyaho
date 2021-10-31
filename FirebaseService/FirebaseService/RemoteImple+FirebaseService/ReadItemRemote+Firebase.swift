//
//  ReadItemRemote+Firebase.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/09/18.
//

import Foundation

import RxSwift

import Domain
import DataStore


extension FirebaseServiceImple {
    
    public func requestLoadMyItems(for memberID: String) -> Maybe<[ReadItem]> {
        guard let _ = self.signInMemberID else {
            return .empty()
        }
        return .error(RemoteErrors.notFound("not implemented", reason: nil))
    }
    
    public func requestLoadCollectionItems(collectionID: String) -> Maybe<[ReadItem]> {
        guard let _ = self.signInMemberID else {
            return .empty()
        }
        return .error(RemoteErrors.notFound("not implemented", reason: nil))
    }
    
    public func requestUpdateReadCollection(_ collection: ReadCollection) -> Maybe<Void> {
        guard let _ = self.signInMemberID else {
            return .empty()
        }
        return .error(RemoteErrors.notFound("not implemented", reason: nil))
    }
    
    public func requestUpdateReadLink(_ link: ReadLink) -> Maybe<Void> {
        guard let _ = self.signInMemberID else {
            return .empty()
        }
        return .error(RemoteErrors.notFound("not implemented", reason: nil))
    }
    
    public func requestLoadCollection(collectionID: String) -> Maybe<ReadCollection> {
        guard let _ = self.signInMemberID else {
            return .empty()
        }
        return .error(RemoteErrors.notFound("not implemented", reason: nil))
    }
    
    public func requestUpdateItem(_ params: ReadItemUpdateParams) -> Maybe<Void> {
        guard let _ = self.signInMemberID else {
            return .empty()
        }
        return .error(RemoteErrors.notFound("not implemented", reason: nil))
    }
    
    public func requestFindLinkItem(using url: String) -> Maybe<ReadLink?> {
        guard let _ = self.signInMemberID else {
            return .just(nil)
        }
        return .error(RemoteErrors.notFound("not implemented", reason: nil))
    }
}
