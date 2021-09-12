//
//  ReadLink.swift
//  Domain
//
//  Created by sudo.park on 2021/09/13.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public struct ReadLink: ReadItem {
    
    private static let uidPrefix = "ri"
    
    public let uid: String
    public let parentID: String?
    public let link: String
    public let createdAt: TimeStamp
    public var lastUpdatedAt: TimeStamp
    public var customName: String?
    public var priority: ReadPriority?
    public var categories: [Category] = []
    
    public init(uid: String, parentID: String?,
                link: String, createAt: TimeStamp, lastUpdated: TimeStamp) {
        self.uid = uid
        self.parentID = parentID
        self.link = link
        self.createdAt = createAt
        self.lastUpdatedAt = lastUpdated
    }
    
    public init(parentID: String?, link: String) {
        self.uid = "\(Self.uidPrefix):\(UUID().uuidString)"
        self.parentID = parentID
        self.link = link
        self.createdAt = TimeStamp.now()
        self.lastUpdatedAt = TimeStamp.now()
    }
}
