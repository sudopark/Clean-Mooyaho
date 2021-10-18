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
    public let destDevID: String
    
    public var title: String?
    public var message: String?
    
    public init(uid: String, itemID: String, destDevID: String) {
        self.uid = uid
        self.itemID = itemID
        self.destDevID = destDevID
    }
    
    public init(itemID: String, destDevID: String) {
        self.uid = "\(Self.uidPrefix)-\(UUID().uuidString)"
        self.itemID = itemID
        self.destDevID = destDevID
    }
}
