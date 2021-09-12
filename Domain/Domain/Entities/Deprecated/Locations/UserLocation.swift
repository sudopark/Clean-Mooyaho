//
//  UserLocation.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/05/03.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public struct LastLocation {
    
    public let coordinate: Coordinate
    public let timeStamp: TimeInterval
    
    public init(lattitude: Double, longitude: Double, timeStamp: TimeInterval) {
        self.coordinate = .init(latt: lattitude, long: longitude)
        self.timeStamp = timeStamp
    }
    
    public var lattitude: Double {
        return self.coordinate.latt
    }
    public var longitude: Double {
        return self.coordinate.long
    }
}

public struct UserLocation {
    
    public let userID: String
    public let lastLocation: LastLocation
    
    public init(userID: String, lastLocation: LastLocation) {
        self.userID = userID
        self.lastLocation = lastLocation
    }
}
