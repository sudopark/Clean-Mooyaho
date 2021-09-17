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
    
    public func requestLoadMyItems(for memberID: String) -> Maybe<[ReadItem]> { .empty() }
    
    public func requestLoadCollectionItems(collectionID: String) -> Maybe<[ReadItem]> { .empty() }
    
    public func requestUpdateReadCollection(_ collection: ReadCollection) -> Maybe<Void> { .empty() }
    
    public func requestUpdateReadLink(_ link: ReadLink) -> Maybe<Void> { .empty() }
}
