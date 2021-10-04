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
    
    public func requestLoadMyItems(for memberID: String) -> Maybe<[ReadItem]> { .just([]) }
    
    public func requestLoadCollectionItems(collectionID: String) -> Maybe<[ReadItem]> { .just([]) }
    
    public func requestUpdateReadCollection(_ collection: ReadCollection) -> Maybe<Void> { .just() }
    
    public func requestUpdateReadLink(_ link: ReadLink) -> Maybe<Void> { .just() }
    
    public func requestLoadCollection(for memberID: String, collectionID: String) -> Maybe<ReadCollection> {
        return .error(RemoteErrors.loadFail("not implemented", reason: nil))
    }
}
