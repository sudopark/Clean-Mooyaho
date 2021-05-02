//
//  OwnerShips.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/04/25.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public struct OwnerShips {
    
    public enum Role: String {
        case employee
        case employer
    }
    
    public let memberID: String
    
    public var storeRoleMap: [String: Role] = [:]
}
