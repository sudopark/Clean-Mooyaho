//
//  ReadCollection.swift
//  Domain
//
//  Created by sudo.park on 2021/09/11.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation
import Extensions


// MARK: - ReadCollection

public struct ReadCollection: ReadItem {
    
    private static let uidPrefix = "rc"
    
    public static let rootID = "root_collection"
    
    public let uid: String
    public var ownerID: String?
    public var parentID: String?
    public var name: String
    public let createdAt: TimeStamp
    public var lastUpdatedAt: TimeStamp
    public var priority: ReadPriority?
    public var categoryIDs: [String] = []
    public var remindTime: TimeStamp?
    public var collectionDescription: String?
    
    public init(name: String) {
        self.uid = "\(Self.uidPrefix):\(UUID().uuidString)"
        self.name = name
        self.createdAt = .now()
        self.lastUpdatedAt = .now()
    }
    
    public init(uid: String, name: String,
                createdAt: TimeStamp, lastUpdated: TimeStamp) {
        self.uid = uid
        self.name = name
        self.createdAt = createdAt
        self.lastUpdatedAt = lastUpdated
    }
    
    
    public static func isCollectionID(_ id: String) -> Bool {
        return id.starts(with: "\(uidPrefix):")
    }
}
