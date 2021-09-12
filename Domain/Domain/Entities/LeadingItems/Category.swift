//
//  Category.swift
//  Domain
//
//  Created by sudo.park on 2021/09/11.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public struct Category {
    
    public let name: String
    public let colorCode: Int
    
    public init(name: String, colorCode: Int) {
        self.name = name
        self.colorCode = colorCode
    }
}
