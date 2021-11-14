//
//  ShareItem+Firebase.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/11/14.
//

import Foundation

import RxSwift

import Domain
import DataStore


extension FirebaseServiceImple {
    
    public func requestShare(collection: ReadCollection) -> Maybe<SharedReadCollection> {
        return .empty()
    }
    
    public func requestStopShare(collectionID: String) -> Maybe<Void> {
        return .empty()
    }
    
    public func requestLoadLatestSharedCollections() -> Maybe<[SharedReadCollection]> {
        return .empty()
    }
    
    public func requestLoadSharedCollection(_ collectionID: String) -> Maybe<SharedReadCollection> {
        return .empty()
    }
}
