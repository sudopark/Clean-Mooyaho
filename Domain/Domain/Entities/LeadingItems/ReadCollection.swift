//
//  ReadCollection.swift
//  Domain
//
//  Created by sudo.park on 2021/09/11.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


// MARK: - ReadCollection

public struct ReadCollection: ReadItem {
    
    private static let uidPrefix = "rc"
    
    public let uid: String
    public let parentID: String?
    public let name: String
    public let createdAt: TimeStamp
    public var lastUpdatedAt: TimeStamp
    public var priority: ReadPriority?
    public var categories: [Category] = []
    
    public init(parentID: String?, name: String) {
        self.uid = "\(Self.uidPrefix):\(UUID().uuidString)"
        self.parentID = parentID
        self.name = name
        self.createdAt = .now()
        self.lastUpdatedAt = .now()
    }
    
    public init(uid: String, parentID: String?, name: String,
                createdAt: TimeStamp, lastUpdated: TimeStamp) {
        self.uid = uid
        self.parentID = parentID
        self.name = name
        self.createdAt = createdAt
        self.lastUpdatedAt = lastUpdated
    }
}
