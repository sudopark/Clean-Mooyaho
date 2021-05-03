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
    
    public let tagType: String
    public let creatorID: String
    public let keyword: String
    
    public init(type: String, creatorID: String, keyword: String) {
        self.tagType = type
        self.creatorID = creatorID
        self.keyword = keyword
    }
    
    public init(placeCategory keyword: String) {
        self.tagType = Self.placeCategoryType
        self.creatorID = Self.serviceDefined
        self.keyword = keyword
    }
    
    public var isPlaceCategoryType: Bool {
        return self.tagType == Self.placeCategoryType
    }
}


public typealias PlaceCategoryTag = Tag

extension PlaceCategoryTag {
    
    private static var placeCategoryType: String { "placeCategory" }
    private static var serviceDefined: String { "service" }
    
    public init(placeCat keyword: String) {
        self.tagType = Self.placeCategoryType
        self.creatorID = Self.serviceDefined
        self.keyword = keyword
    }
}


extension Tag: Equatable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.tagType == rhs.tagType
            && lhs.creatorID == rhs.creatorID
            && lhs.keyword == rhs.keyword
    }
}


// MARK: - Tag Types

public enum TagType: String {
    
    case placeCategory
    case userComments
    case userFeeling
    
    public var identifier: String {
        switch self {
        case .placeCategory: return "placeCategory"
        case .userComments: return "userComments"
        case .userFeeling: return "userFeeling"
        }
    }
}
