//
//  ReadingList+Mapping.swift
//  ReadingList
//
//  Created by sudo.park on 2022/07/30.
//

import Foundation

import Domain
import Remote


enum ReadingListMappingKey: String {
    
    static var rootListID: String { "root" }
    
    case uid
    case ownerID = "oid"
    case parentID = "pid"
    case createdAt = "crt_at"
    case lastUpdatedAt = "lst_up_at"
    case priority
    case categoryIDs = "cate_ids"
    
    // key for collection
    case name = "nm"
    case collectionDescription = "cllc_desc"
}

extension ReadingList: JsonConvertable {
    
    private typealias Keys = ReadingListMappingKey
    
    public static var identifierKey: String {
        return Keys.uid.rawValue
    }
    
    public var identifier: String { self.uuid }
    
    public init(json: [String : Any]) throws {
        let uid: String = try json.value(Keys.uid)
        self.init(
            uuid: uid,
            name: try json.value(Keys.name),
            isRootList: uid == ReadingList.rootListID
        )
        self.ownerID = try? json.value(Keys.ownerID)
        self.parentID = try? json.value(Keys.parentID)
        self.createdAt = try json.value(Keys.createdAt)
        self.lastUpdatedAt = try json.value(Keys.lastUpdatedAt)
        self.description = try? json.value(Keys.collectionDescription)
        self.categoryIds = (try? json.value(Keys.categoryIDs)) ?? []
        self.priorityID = try? json.value(Keys.priority)
    }
    
    public func asJson() -> [String : Any] {
        var sender: [String: Any] = [:]
        sender[Keys.uid.rawValue] = self.uuid
        sender[Keys.ownerID.rawValue] = self.ownerID
        sender[Keys.parentID.rawValue] = self.parentID
        sender[Keys.createdAt.rawValue] = self.createdAt
        sender[Keys.lastUpdatedAt.rawValue] = self.lastUpdatedAt
        sender[Keys.priority.rawValue] = self.priorityID
        sender[Keys.categoryIDs.rawValue] = self.categoryIds
        sender[Keys.name.rawValue] = self.name
        sender[Keys.collectionDescription.rawValue] = self.description
        return sender
    }
}
