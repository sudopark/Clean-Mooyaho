//
//  ReadRemindMessage.swift
//  Domain
//
//  Created by sudo.park on 2021/10/18.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public struct ReadRemindMessage: Message {
    
    public let itemID: String
    public let scheduledTime: TimeStamp
    
    public var title: String {
        return "Read Remind Notification".localized
    }
    public var message: String?
    
    public init(itemID: String, scheduledTime: TimeStamp) {
        self.itemID = itemID
        self.scheduledTime = scheduledTime
    }
}


extension ReadRemindMessage {
    
    public static var defaultReadLinkMessage: String {
        return "It's time to read".localized
    }
}
