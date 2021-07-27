//
//  LocationUtils.swift
//  Domain
//
//  Created by sudo.park on 2021/05/11.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation
import CoreLocation

extension Coordinate {
    
    public func distance(from: Coordinate) -> Meters {
        let cllFrom = CLLocation(latitude: from.latt, longitude: from.long)
        let cllTo = CLLocation(latitude: self.latt, longitude: self.long)
        return cllTo.distance(from: cllFrom)
    }
}


extension Meters {
    
    public func asDistanceText() -> String {
        
        if self >= 1000 {
            return String(format: "%.1f", self/1000) + "km"
        } else {
            return String(format: "%.1f", self) + "m"
        }
    }
}
