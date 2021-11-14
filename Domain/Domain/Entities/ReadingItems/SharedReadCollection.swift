//
//  SharedReadCollection.swift
//  Domain
//
//  Created by sudo.park on 2021/11/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public struct SharedReadCollection: ReadItem {
    
    public let uid: String
    public let name: String
    public var ownerID: String?
    public var parentID: String?
    public let createdAt: TimeStamp
    public var lastUpdatedAt: TimeStamp
    public var priority: ReadPriority? = nil
    public var remindTime: TimeStamp? = nil
    public var categoryIDs: [String] = []
    
    public static var shareHost: String { "share" }
    
    public static var sharePath: String { "collection" }
    
    public var fullSharePath: String {
        return "\(Self.shareHost)/\(Self.sharePath)?id=\(uid)"
    }
    
    public init(collection: ReadCollection) {
        self.uid = collection.uid
        self.name = collection.name
        self.ownerID = collection.ownerID
        self.parentID = collection.parentID
        self.createdAt = collection.createdAt
        self.lastUpdatedAt = collection.lastUpdatedAt
        self.categoryIDs = collection.categoryIDs
    }
    
    public init(uid: String, name: String,
                createdAt: TimeStamp, lastUpdated: TimeStamp) {
        self.uid = uid
        self.name = name
        self.createdAt = createdAt
        self.lastUpdatedAt = lastUpdated
    }
}
