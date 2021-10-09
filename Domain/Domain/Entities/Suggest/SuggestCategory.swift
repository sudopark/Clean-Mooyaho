//
//  SuggestCategory.swift
//  Domain
//
//  Created by sudo.park on 2021/10/09.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public struct SuggestCategory {
    
    public let ownerID: String?
    public let category: ItemCategory
    
    public init(ownerID: String? = nil, category: ItemCategory) {
        self.ownerID = ownerID
        self.category = category
    }
}


public struct SuggestCategoryCollection {
    
    public let query: String
    public let currentPage: Int?
    public let categories: [SuggestCategory]
    public let isFinalPage: Bool
    
    public init(query: String, currentPage: Int? = nil,
                categories: [SuggestCategory], isFinalPage: Bool) {
        self.query = query
        self.currentPage = currentPage
        self.categories = categories
        self.isFinalPage = isFinalPage
    }

    public static func empty(_ query: String = "") -> Self {
        return SuggestCategoryCollection(query: query, currentPage: nil, categories: [], isFinalPage: true)
    }
}
