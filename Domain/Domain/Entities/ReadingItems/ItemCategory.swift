//
//  ItemCategory.swift
//  Domain
//
//  Created by sudo.park on 2021/09/11.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import Prelude
import Optics


public struct ItemCategory: Equatable {
    
    private static var categoryPrefix: String { "item_cate" }
    
    public let uid: String
    public let name: String
    public let colorCode: String
    public var ownerID: String?
    public let createdAt: TimeStamp
    
    public init(uid: String, name: String, colorCode: String, createdAt: TimeStamp) {
        self.uid = uid
        self.name = name
        self.colorCode = colorCode
        self.createdAt = createdAt
    }
    
    public init(name: String, colorCode: String) {
        self.uid = "\(Self.categoryPrefix):\(UUID().uuidString)"
        self.name = name
        self.colorCode = colorCode
        self.createdAt = .now()
    }
}

extension ItemCategory {
    
    public static var colorCodes: [String] {
        return [
            "#f44336",
            "#e91e63",
            "#9c27b0",
            "#3f51b5",
            "#00838f",
            "#00796b",
            "#827717",
            "#ff6f00",
            "#5d4037",
            "#424242",
            "#546e7a"
        ]
    }
}


extension ItemCategory {
    
    public func applyingChange(_ params: UpdateCategoryAttrParams) -> ItemCategory {
        return ItemCategory(uid: self.uid,
                            name: params.newName ?? self.name,
                            colorCode: params.newColorCode ?? self.colorCode,
                            createdAt: self.createdAt)
            |> \.ownerID .~ self.ownerID
    }
}
