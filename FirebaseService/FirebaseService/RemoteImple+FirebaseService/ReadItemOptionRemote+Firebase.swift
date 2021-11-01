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
        let order: Maybe<CollectionCustomOrders?> = self.load(docuID: collectionID, in: .readCollectionCustomOrders)
        return order.map { $0?.itemIDs }
    }
    
    public func requestUpdateReadItemCustomOrder(for collection: String, itemIDs: [String]) -> Maybe<Void> {
        guard let _ = self.signInMemberID else {
            return .empty()
        }
        let order = CollectionCustomOrders(collectionID: collection, itemIDs: itemIDs)
        return self.save(order, at: .readCollectionCustomOrders, merging: true)
    }
}
