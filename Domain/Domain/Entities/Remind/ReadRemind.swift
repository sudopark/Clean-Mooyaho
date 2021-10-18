//
//  ReadRemind.swift
//  Domain
//
//  Created by sudo.park on 2021/10/18.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public struct ReadRemind {
    
    public let uid: String
    public let itemID: String
    
    public var scheduledTime: TimeStamp
    
    private static var itemIDPrefix: String {
        return "rm"
    }
    
    public init(uid: String, itemID: String, scheduledTime: TimeStamp) {
        self.uid = uid
        self.itemID = itemID
        self.scheduledTime = scheduledTime
    }
    
    public init(itemID: String, scheduledTime: TimeStamp) {
        self.uid = "rm-\(UUID().uuidString)"
        self.itemID = itemID
        self.scheduledTime = scheduledTime
    }
}
