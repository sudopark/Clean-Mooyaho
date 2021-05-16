//
//  DistanceUtills.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/05/16.
//

import Foundation

import Domain

protocol DistanceCalculatable {
    
    var centerPosition: (latt: Double, long: Double) { get }
}

extension Place: DistanceCalculatable {
    var centerPosition: (latt: Double, long: Double) {
        return (self.coordinate.latt, self.coordinate.long)
    }
}

extension PlaceSnippet: DistanceCalculatable {
    
    var centerPosition: (latt: Double, long: Double) {
        return (self.latt, self.long)
    }
}


extension Hooray: DistanceCalculatable {
    
    var centerPosition: (latt: Double, long: Double) {
        return (self.location.latt, self.location.long)
    }
}

extension Array where Element: DistanceCalculatable {
    
    func withIn(kilometers: Double, center2D: CLLocationCoordinate2D) -> [Element] {
        return self.compactMap { element -> Element? in
            let (x, y) = (element.centerPosition.latt, element.centerPosition.long)
            let coordi = CLLocation(latitude: x, longitude: y)
            let center = CLLocation(latitude: center2D.latitude, longitude: center2D.longitude)
            
            let distance = GFUtils.distance(from: center, to: coordi)
            guard distance <= kilometers else { return nil }
            return element
        }
    }
}
