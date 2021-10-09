//
//  ItemCategory.swift
//  Domain
//
//  Created by sudo.park on 2021/09/11.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public struct ItemCategory: Equatable {
    
    private static var categoryPrefix: String { "item_cate" }
    
    public let uid: String
    public let name: String
    public let colorCode: String
    
    public init(uid: String, name: String, colorCode: String) {
        self.uid = uid
        self.name = name
        self.colorCode = colorCode
    }
    
    public init(name: String, colorCode: String) {
        self.uid = "\(Self.categoryPrefix):\(UUID().uuidString)"
        self.name = name
        self.colorCode = colorCode
    }
}
