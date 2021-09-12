//
//  LocationMonitoringOption.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/05/03.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public struct LocationMonitoringOption {
    
    public enum Accuracy {
        case best
        case tenMeters
        case hundredMeters
        case kiloMeters
        case threeKilometers
    }
    
    public let accuracy: Accuracy
    public let distanceFilter: Meters
    
    public init(accuracy: Accuracy, distanceFilter: Meters) {
        self.accuracy = accuracy
        self.distanceFilter = distanceFilter
    }
}
