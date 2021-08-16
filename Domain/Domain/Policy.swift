//
//  Policy.swift
//  Domain
//
//  Created by sudo.park on 2021/07/03.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

public enum Policy {
    
    public static let hoorayMaxSpreadDistance: Meters = 5_1000
    public static let hoorayDefaultSpreadDistance: Meters = 500
    
    public static let hoorayAliveTime: TimeInterval = 24 * 60 * 60 * 1000
    public static let recentHoorayTime: TimeInterval = 30 * 60 * 1000
}
