//
//  ReadLinkItem+Mapping.swift
//  ReadingList
//
//  Created by sudo.park on 2022/07/31.
//

import Foundation

import Domain
import Remote


enum ReadLinkItemMappingKey: String {
    
    case uid
    case ownerID = "oid"
    case parentID = "pid"
    case createdAt = "crt_at"
    case lastUpdatedAt = "lst_up_at"
    case priority
    case categoryIDs = "cate_ids"
    case link
    case customName = "custom_nm"
    case isRed = "is_red"
}


extension ReadLinkItem: JsonMappable {
    
    private typealias Keys = ReadLinkItemMappingKey
    
    public static var identifierKey: String {
        return Keys.uid.rawValue
    }
    
    public init(json: [String : Any]) throws {
        let uid: String = try json.value(Keys.uid)
        self.init(
            uuid: uid,
            link: try json.value(Keys.link)
        )
        self.ownerID = try? json.value(Keys.ownerID)
        self.createdAt = try json.value(Keys.createdAt)
        self.lastUpdatedAt = try json.value(Keys.lastUpdatedAt)
        self.categoryIds = (try? json.value(Keys.categoryIDs)) ?? []
        self.priorityID = try? json.value(Keys.priority)
        self.customName = try? json.value(Keys.customName)
        self.isRead = (try? json.value(Keys.isRed)) ?? false
    }
}
