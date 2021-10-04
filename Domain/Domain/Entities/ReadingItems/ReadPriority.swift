//
//  ReadPriority.swift
//  Domain
//
//  Created by sudo.park on 2021/09/11.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public enum ReadPriority: Int, CaseIterable {
    case beforeDying = 0
    case someDay = 10
    case thisWeek = 20
    case today = 30
    case beforeGoToBed = 40
    case onTheWaytoWork = 50
    case afterAWhile = 60
}

extension ReadPriority {
    
    public static func isAscendingOrder(_ lhs: ReadPriority?, rhs: ReadPriority?) -> Bool {
        switch (lhs, rhs) {
        case (.some, .none): return true
        case (.none, .some): return false
        case let (.some(p1), .some(p2)): return p1.rawValue < p2.rawValue
        default: return false
        }
    }
    
    public static func isDescendingOrder(_ lhs: ReadPriority?, rhs: ReadPriority?) -> Bool {
        switch (lhs, rhs) {
        case (.some, .none): return true
        case (.none, .some): return false
        case let (.some(p1), .some(p2)): return p1.rawValue > p2.rawValue
        default: return false
        }
    }
}
