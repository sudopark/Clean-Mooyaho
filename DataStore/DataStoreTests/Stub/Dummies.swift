//
//  Dummies.swift
//  DataStoreTests
//
//  Created by ParkHyunsoo on 2021/05/02.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import Domain

@testable import DataStore


extension UserLocation {
    
    static func dummy(_ int: Int) -> UserLocation {
        return .init(userID: "uid:\(int)", lastLocation: .init(lattitude: Double(int), longitude: Double(int), timeStamp: Double(int)))
    }
}
