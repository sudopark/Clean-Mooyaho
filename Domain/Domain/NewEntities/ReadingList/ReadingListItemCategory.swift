//
//  ReadingListItemCategory.swift
//  Domain
//
//  Created by sudo.park on 2022/08/23.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation

import Extensions


public struct ReadingListItemCategory: Sendable {
    
    private static var uidPrefix: String { "item_cate" }
    
    public let uid: String
    public var name: String
    public var colorCode: String
    public let createdAt: TimeStamp
    
    public init(
        uid: String,
        name: String,
        colorCode: String,
        createdAt: TimeStamp
    ) {
        self.uid = uid
        self.name = name
        self.colorCode = colorCode
        self.createdAt = createdAt
    }
    
    public init(name: String, colorCode: String) {
        self.uid = "\(Self.uidPrefix):\(UUID().uuidString)"
        self.name = name
        self.colorCode = colorCode
        self.createdAt = .now()
    }
}
