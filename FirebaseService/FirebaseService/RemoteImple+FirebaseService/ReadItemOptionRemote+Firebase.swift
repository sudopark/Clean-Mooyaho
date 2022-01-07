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
    
    private typealias Key = CollectionCustomOrders.MappingKeys
    
    public func requestLoadReadItemCustomOrder(for collectionID: String) -> Maybe<[String]?> {
        guard let ownerID = self.signInMemberID else {
            return .empty()
        }
        let combineID = CollectionCustomOrders(ownerID: ownerID, collectionID: collectionID).combineID
        let order: Maybe<CollectionCustomOrders?> = self.load(docuID: combineID, in: .readCollectionCustomOrders)
        return order.map { $0?.itemIDs }
    }
    
    public func requestUpdateReadItemCustomOrder(for collection: String, itemIDs: [String]) -> Maybe<Void> {
        guard let ownerID = self.signInMemberID else {
            return .empty()
        }
        
        let order = CollectionCustomOrders(ownerID: ownerID, collectionID: collection, itemIDs: itemIDs)
        return self.save(order, at: .readCollectionCustomOrders, merging: true)
    }
}
