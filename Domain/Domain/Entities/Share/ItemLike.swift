//
//  LikeItem.swift
//  Domain
//
//  Created by sudo.park on 2021/11/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public struct ItemLike {
    
    public let itemID: String
    public var likeMemberIDsSet: Set<String> = []
    
    public init(itemID: String) {
        self.itemID = itemID
    }
}
