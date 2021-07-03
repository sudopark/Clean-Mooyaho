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
        public var postalCode: String?
        
        public var postalAddress: String?
        
        public var address: String {
            
            let defaultAddress = [self.placeName, self.subLocality, self.thoroughfare,
                                  self.locality, self.postalCode].compactMap{ $0 }
                .joined(separator: ", ")
            
            return postalAddress ?? defaultAddress
        }
        
        public init(placeName: String?,
                    subLocality: String?,
                    thoroughfare: String?,
                    locality: String?,
                    postalCode: String?,
                    postalAddress: String?) {
            self.placeName = placeName
            self.subLocality = subLocality
            self.thoroughfare = thoroughfare
            self.locality = locality
            self.postalCode = postalCode
            self.postalAddress = postalAddress
        }
        
        public init(address: String) {
            self.postalAddress = address
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
