//
//  RemindTime.swift
//  Domain
//
//  Created by sudo.park on 2021/11/11.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public struct RemindTime {
    
    public let hour: Int
    public let minute: Int
    
    public init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }
    
    public static var `default`: RemindTime {
        return .init(hour: 10, minute: 0)
    }
}
