//
//  Tags.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/05/04.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


// MARK: - Tag

public struct Tag {
    
    public enum TagType: String {
        
        case placeCategory
        case userComments
        case userFeeling
    }
    
    public let tagType: TagType
    public let keyword: String
    
    public init(type: TagType, keyword: String) {
        self.tagType = type
        self.keyword = keyword
    }
}


// MARK: - PlaceCategoryTag

public typealias PlaceCategoryTag = Tag

extension PlaceCategoryTag {
    
    private static var serviceDefined: String { "service" }
    
    public init(placeCat keyword: String) {
        self.tagType = .placeCategory
        self.keyword = keyword
    }
}


extension Tag: Equatable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.tagType == rhs.tagType
            && lhs.keyword == rhs.keyword
    }
}



// MARK: - tag suggest resultCollection

public struct SuggestTagResultCollection {
    
    enum TagList {
        case cached(_ tags: [Tag])
        case remote(_ tags: [Tag])
        case combined(_ tags: [Tag])
    }
    
    public let query: String
    public let cursor: String?
    private let pageTags: TagList
    
    public var tags: [Tag] {
        switch self.pageTags {
        case let .cached(value),
             let .remote(value),
             let .combined(value) : return value
        }
    }
    
    public init(query: String, tags: [Tag], cursor: String?) {
        self.query = query
        self.pageTags = .combined(tags)
        self.cursor = cursor
    }
}
