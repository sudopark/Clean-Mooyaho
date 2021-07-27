//
//  Coordinate.swift
//  Domain
//
//  Created by sudo.park on 2021/07/28.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


// MARK: - Coordinate

public struct Coordinate {
    
    public let latt: Double
    public let long: Double
    
    public init(latt: Double, long: Double) {
        self.latt = latt
        self.long = long
    }
}


// MARK: - PlaceMark

public enum PlaceMark {
    
    public struct DetailInfos {
        public var placeName: String?
        public var subLocality: String?
        public var thoroughfare: String?
        public var locality: String?
        public var city: String?
        public var postalCode: String?
    }
    
    case system(DetailInfos)
    case userDefine(String)
        
    public var address: String {
        
        switch self {
        case let .system(info):
            var sender = ""
            if let code = info.postalCode {
                sender = "(\(code)) "
            }
            if let name = info.placeName {
                sender = "\(sender)\(name)"
            } else if let subLocal = info.subLocality {
                sender = "\(sender)\(subLocal)"
            } else if let street = info.thoroughfare {
                sender = "\(sender)\(street)"
            }
            
            if let local = info.locality {
                sender = "\(sender) \(local)"
            }
            
            if let city = info.city {
                sender = "\(sender) \(city)"
            }
            return sender
            
        case let .userDefine(addr):
            return addr
        }
    }
    
    public init(city: String?,
                placeName: String?,
                subLocality: String?,
                thoroughfare: String?,
                locality: String?,
                postalCode: String?) {
        let info = DetailInfos(placeName: placeName, subLocality: subLocality,
                               thoroughfare: thoroughfare, locality: locality,
                               city: city, postalCode: postalCode)
        self = .system(info)
    }
    
    public init(address: String) {
        self = .userDefine(address)
    }
}


public struct Location {
    
    public let coordinate: Coordinate
    public var placeMark: PlaceMark
    
    public init(coordinate: Coordinate, placeMark: PlaceMark) {
        self.coordinate = coordinate
        self.placeMark = placeMark
    }
}
