//
//  ReadItem.swift
//  Domain
//
//  Created by sudo.park on 2021/09/11.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public protocol ReadItem {
    
    var uid: String { get }
    var ownerID: String? { get set }
    var parentID: String? { get set }
    var createdAt: TimeStamp { get }
    var lastUpdatedAt: TimeStamp { get set }
    var priority: ReadPriority? { get set }
    var categories: [ItemCategory] { get set }
}