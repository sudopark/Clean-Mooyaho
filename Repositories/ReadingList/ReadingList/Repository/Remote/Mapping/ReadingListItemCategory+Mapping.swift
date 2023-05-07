//
//  ReadingListItemCategory+Mapping.swift
//  ReadingList
//
//  Created by sudo.park on 2022/08/29.
//

import Foundation

import Domain
import Remote

enum ReadingListItemCategoryMappingKey: String {
    case uid
    case name = "nm"
    case colorCode = "cc"
    case createdAt = "ct"
    case ownerID = "oid"
}


struct MemberItemCategory: JsonConvertable {
    
    private typealias Keys = ReadingListItemCategoryMappingKey
    
    let ownerID: String
    let category: ReadingListItemCategory
    
    var identifier: String { self.category.uid }
    static var identifierKey: String { Keys.uid.rawValue }
    
    init(_ ownerID: String, _ category: ReadingListItemCategory) {
        self.ownerID = ownerID
        self.category = category
    }
    
    init(json: [String : Any]) throws {
        self.ownerID = try json.value(Keys.ownerID)
        self.category = .init(
            uid: try json.value(Keys.uid),
            name: try json.value(Keys.name),
            colorCode: try json.value(Keys.colorCode),
            createdAt: try json.value(Keys.createdAt)
        )
    }
    
    func asJson() -> [String : Any] {
        var sender: [String: Any] = [:]
        sender[Keys.uid.rawValue] = self.category.uid
        sender[Keys.name.rawValue] = self.category.name
        sender[Keys.colorCode.rawValue] = self.category.colorCode
        sender[Keys.createdAt.rawValue] = self.category.createdAt
        sender[Keys.ownerID.rawValue] = self.ownerID
        return sender
    }
}
