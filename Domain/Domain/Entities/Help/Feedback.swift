//
//  Feedback.swift
//  Domain
//
//  Created by sudo.park on 2021/12/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public struct Feedback {
    
    public let uuid: String
    public let userID: String
    public var osVersion: String?
    public var appVersion: String?
    public var deviceModel: String?
    public var message: String?
    public var contract: String?
    
    public init(userID: String) {
        self.uuid = UUID().uuidString
        self.userID = userID
    }
    
    public init(uuid: String, userID: String) {
        self.uuid = uuid
        self.userID = userID
    }
}
