//
//  SharedReadCollection.swift
//  Domain
//
//  Created by sudo.park on 2021/11/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation
import Extensions


public protocol SharedReadItem: ReadItem { }

extension SharedReadItem {
    
    public var priority: ReadPriority? {
        get { nil } set { }
    }
    
    public var remindTime: TimeStamp? {
        get { nil } set { }
    }
}


public struct SharedReadCollection: SharedReadItem {
    
    public let shareID: String
    public let uid: String
    public let name: String
    public var description: String?
    public var ownerID: String?
    public var parentID: String?
    public let createdAt: TimeStamp
    public var lastUpdatedAt: TimeStamp
    public var categoryIDs: [String] = []
    
    public static var shareHost: String { "share" }
    
    public static var sharePath: String { "collection" }
    
    public var fullSharePath: String {
        return "\(Self.shareHost)/\(Self.sharePath)?id=\(shareID)"
    }
    
    public init(shareID: String, collection: ReadCollection) {
        self.shareID = shareID
        self.uid = collection.uid
        self.name = collection.name
        self.description = collection.collectionDescription
        self.ownerID = collection.ownerID
        self.parentID = collection.parentID
        self.createdAt = collection.createdAt
        self.lastUpdatedAt = collection.lastUpdatedAt
        self.categoryIDs = collection.categoryIDs
    }
    
    public init(subCollection collection: ReadCollection) {
        self.init(shareID: "", collection: collection)
    }
    
    public init(shareID: String, uid: String, name: String,
                createdAt: TimeStamp, lastUpdated: TimeStamp) {
        self.shareID = shareID
        self.uid = uid
        self.name = name
        self.createdAt = createdAt
        self.lastUpdatedAt = lastUpdated
    }
}


// MARK: - SharingCollectionIndex

public struct SharingCollectionIndex {
    
    public let shareID: String
    public let ownerID: String
    public let collectionID: String
    
    public init(shareID: String, ownerID: String, collectionID: String) {
        self.shareID = shareID
        self.ownerID = ownerID
        self.collectionID = collectionID
    }
}
