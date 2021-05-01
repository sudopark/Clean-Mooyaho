//
//  Manager.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/04/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public struct Manager: Seller {
    
    // store properties
    public let storeID: String
    
    // member properties
    public let memberID: String
    
    public var nickName: String?
    
    public var icon: ImageSource?
    
    public init(storeID: String, memberID: String) {
        self.storeID = storeID
        self.memberID = memberID
    }
}
