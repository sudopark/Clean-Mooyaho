//
//  SuggestReadItemIndex.swift
//  Domain
//
//  Created by sudo.park on 2021/11/21.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public struct SearchReadItemIndex {
    
    public let itemID: String
    public let isCollection: Bool
    public let displayName: String
    public var categoryIDs: [String] = []
    public var description: String?
    
    public init(itemID: String, isCollection: Bool = true, displayName: String) {
        self.itemID = itemID
        self.isCollection = isCollection
        self.displayName = displayName
    }
}
