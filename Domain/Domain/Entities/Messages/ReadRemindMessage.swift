//
//  ReadRemindMessage.swift
//  Domain
//
//  Created by sudo.park on 2021/10/18.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public struct ReadRemindMessage {
    
    private static var uidPrefix: String  { "rmm" }
    
    public let uid: String
    public let itemID: String
    
    public var title: String {
        return "Read Remind Notification".localized
    }
    public var message: String?
    
    public init(uid: String, itemID: String) {
        self.uid = uid
        self.itemID = itemID
    }
    
    public init(itemID: String) {
        self.uid = "\(Self.uidPrefix)-\(UUID().uuidString)"
        self.itemID = itemID
    }
}


extension ReadRemindMessage {
    
    public static var defaultReadLinkMessage: String {
        return "It's time to read".localized
    }
}
