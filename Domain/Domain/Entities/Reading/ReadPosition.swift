//
//  ReadPosition.swift
//  Domain
//
//  Created by sudo.park on 2022/05/28.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation
import Extensions


public struct ReadPosition {
    
    public let itemID: String
    public var position: Double
    public var saved: TimeStamp
    
    public init(itemID: String,
                position: Double,
                saved: TimeStamp? = nil) {
        self.itemID = itemID
        self.position = position
        self.saved = saved ?? .now()
    }
}
