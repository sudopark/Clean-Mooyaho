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
    
    private typealias Key = ReadItemMappingKey
    
    public func requestLoadMyItems(for memberID: String) -> Maybe<[ReadItem]> {
        guard let memberID = self.signInMemberID else {
            return .empty()
        }
        
        let collectionRef = self.fireStoreDB.collection(.readCollection)
        let collectionQuery = collectionRef
            .whereField(Key.ownerID.rawValue, isEqualTo: memberID)
            .whereField(Key.parentID.rawValue, isEqualTo: "root")
        
        let linkRef = self.fireStoreDB.collection(.readLinks)
        let linksQuery = linkRef
            .whereField(Key.ownerID.rawValue, isEqualTo: memberID)
            .whereField(Key.parentID.rawValue, isEqualTo: "root")
        
        return self.requestLoadMatchingItems(collectionQuery, linksQuery)
    }
    
    public func requestLoadCollectionItems(collectionID: String) -> Maybe<[ReadItem]> {
        guard let _ = self.signInMemberID else {
            return .empty()
        }
        
        let collectionRef = self.fireStoreDB.collection(.readCollection)
        let collectionQuery = collectionRef
            .whereField(Key.parentID.rawValue, isEqualTo: collectionID)
        
        let linkRef = self.fireStoreDB.collection(.readLinks)
        let linksQuery = linkRef
            .whereField(Key.parentID.rawValue, isEqualTo: collectionID)
        
        
        return self.requestLoadMatchingItems(collectionQuery, linksQuery)
    }
    
    private func requestLoadMatchingItems(_ collectionQuery: Query,
                                          _ linksQuery: Query) -> Maybe<[ReadItem]> {
        let collections: Maybe<[ReadCollection]> = self.load(query: collectionQuery).catchAndReturn([])
        let links: Maybe<[ReadLink]> = self.load(query: linksQuery).catchAndReturn([])
        let combine: ([ReadCollection], [ReadLink]) -> [ReadItem] = { $0 + $1 }
        return Observable
            .combineLatest(collections.asObservable(), links.asObservable(), resultSelector: combine)
            .asMaybe()
    }
    
    public func requestUpdateReadCollection(_ collection: ReadCollection) -> Maybe<Void> {
        guard let _ = self.signInMemberID else {
            return .empty()
        }
        return self.save(collection, at: .readCollection, merging: true)
    }
    
    public func requestUpdateReadLink(_ link: ReadLink) -> Maybe<Void> {
        guard let _ = self.signInMemberID else {
            return .empty()
        }
        return self.save(link, at: .readLinks, merging: true)
    }
    
    public func requestLoadCollection(collectionID: String) -> Maybe<ReadCollection> {
        guard let _ = self.signInMemberID else {
            return .empty()
        }
        let throwWhenNotExists: (ReadCollection?) throws -> ReadCollection
        throwWhenNotExists = { collection in
            guard let collection = collection else {
                throw RemoteErrors.notFound("ReadCollection", reason: nil)
            }
            return collection
        }
        return self.load(docuID: collectionID, in: .readCollection)
            .map(throwWhenNotExists)
    }
    
    public func requestUpdateItem(_ params: ReadItemUpdateParams) -> Maybe<Void> {
        guard let _ = self.signInMemberID else {
            return .empty()
        }
        let newItem = params.applyChanges()
        switch newItem {
        case let collection as ReadCollection:
            return self.requestUpdateReadCollection(collection)
            
        case let link as ReadLink:
            return self.requestUpdateReadLink(link)
            
        default:
            return .error(RemoteErrors.invalidRequest("invalid read item type"))
        }
    }
    
    public func requestFindLinkItem(using url: String) -> Maybe<ReadLink?> {
        guard let _ = self.signInMemberID else {
            return .just(nil)
        }
        
        // TODO: error 떨구는지 nil로 나오는지 확인 필요
        let linkRef = self.fireStoreDB.collection(.readLinks)
        let query = linkRef.whereField(Key.link.rawValue, isEqualTo: url)
        return self.load(query: query).map { $0.first }
    }
}
