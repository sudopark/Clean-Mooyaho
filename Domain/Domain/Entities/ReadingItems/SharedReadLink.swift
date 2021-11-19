//
//  SharedReadLink.swift
//  Domain
//
//  Created by sudo.park on 2021/11/17.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import Prelude
import Optics


public struct SharedReadLink: SharedReadItem {
    
    public let uid: String
    public var ownerID: String?
    public var parentID: String?
    public let link: String
    public let createdAt: TimeStamp
    public var lastUpdatedAt: TimeStamp
    public var customName: String?
    public var categoryIDs: [String] = []
    
    public init(link: ReadLink) {
        self.uid = link.uid
        self.link = link.link
        self.customName = link.customName
        self.ownerID = link.ownerID
        self.parentID = link.parentID
        self.createdAt = link.createdAt
        self.lastUpdatedAt = link.lastUpdatedAt
        self.categoryIDs = link.categoryIDs
    }
    
    public init(uid: String, link: String,
                createdAt: TimeStamp, lastUpdated: TimeStamp) {
        self.uid = uid
        self.link = link
        self.createdAt = createdAt
        self.lastUpdatedAt = lastUpdated
    }
}


extension SharedReadLink {
    
    public func asReadLink() -> ReadLink {
        return ReadLink(uid: self.uid, link: self.link,
                        createAt: self.createdAt, lastUpdated: self.lastUpdatedAt)
            |> \.parentID .~ self.parentID
            |> \.customName .~ self.customName
            |> \.categoryIDs .~ self.categoryIDs
    }
}
