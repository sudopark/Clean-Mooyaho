//
//  UserLocation.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/05/03.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public struct LastLocation {
    
    public struct PlaceMark {
        
        public var placeName: String?
        public var subLocality: String?
        public var thoroughfare: String?
        public var locality: String?
        public var city: String?
        public var postalCode: String?
        
        public var userDefineAddress: String?

        public var address: String {
            
            var sender = ""
            if let code = postalCode {
                sender = "(\(code)) "
            }
            if let name = self.placeName {
                sender = "\(sender)\(name)"
            } else if let subLocal = self.subLocality {
                sender = "\(sender)\(subLocal)"
            } else if let street = self.thoroughfare {
                sender = "\(sender)\(street)"
            }
            
            if let local = self.locality {
                sender = "\(sender) \(local)"
            }
            
            if let city = self.city {
                sender = "\(sender) \(city)"
            }
            
            return userDefineAddress ?? sender
        }
        
        public init(city: String?,
                    placeName: String?,
                    subLocality: String?,
                    thoroughfare: String?,
                    locality: String?,
                    postalCode: String?) {
            self.city = city
            self.placeName = placeName
            self.subLocality = subLocality
            self.thoroughfare = thoroughfare
            self.locality = locality
            self.postalCode = postalCode
        }
        
        public init(address: String) {
            self.userDefineAddress = address
        }
    }
    
    public let lattitude: Double
    public let longitude: Double
    public let timeStamp: TimeInterval
    public var placeMark: PlaceMark?
    
    public init(lattitude: Double, longitude: Double, timeStamp: TimeInterval) {
        self.lattitude = lattitude
        self.longitude = longitude
        self.timeStamp = timeStamp
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


public typealias CurrentPosition = LastLocation
