//
//  ItemCategory.swift
//  Domain
//
//  Created by sudo.park on 2021/09/11.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public struct ItemCategory {
    
    public let name: String
    public let colorCode: String
    
    public init(name: String, colorCode: String) {
        self.name = name
        self.colorCode = colorCode
    }
}
