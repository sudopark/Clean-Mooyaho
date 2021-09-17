//
//  ReadLinkTable.swift
//  DataStore
//
//  Created by sudo.park on 2021/09/18.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import SQLiteService
import Prelude
import Optics

import Domain

struct ReadLinkTable: Table {
    
    typealias EntityType = Entity
    typealias ColumnType = Columns
    
    static var tableName: String { "read_links" }
    
    static func scalar(_ entity: Entity, for column: Columns) -> ScalarType? {
        switch column {
        case .uid: return entity.uid
        case .ownerID: return entity.ownerID
        case .parentID: return entity.parentID
        case .link: return entity.link
        case .createdAt: return entity.createdAt
        case .lastUpdatedAt: return entity.lastUpdatedAt
        case .customName: return entity.customName
        case .pritority: return entity.priority?.rawValue
        }
    }
}

extension ReadLinkTable {
    
    struct Entity: RowValueType {
        
        let uid: String
        let ownerID: String?
        let parentID: String?
        let link: String
        let createdAt: TimeStamp
        let lastUpdatedAt: TimeStamp
        let customName: String?
        let priority: ReadPriority?
        
        init(_ cursor: CursorIterator) throws {
            self.uid = try cursor.next().unwrap()
            self.ownerID = cursor.next()
            self.parentID = cursor.next()
            self.link = try cursor.next().unwrap()
            self.createdAt = try cursor.next().unwrap()
            self.lastUpdatedAt = try cursor.next().unwrap()
            self.customName = cursor.next()
            self.priority = cursor.next().flatMap{ ReadPriority.init(rawValue: $0) }
        }
        
        init(link: ReadLink) {
            self.uid = link.uid
            self.ownerID = link.ownerID
            self.parentID = link.parentID
            self.link = link.link
            self.createdAt = link.createdAt
            self.lastUpdatedAt = link.lastUpdatedAt
            self.customName = link.customName
            self.priority = link.priority
        }
    }
}

extension ReadLinkTable {
    
    enum Columns: String, TableColumn {
        case uid
        case ownerID = "owner_id"
        case parentID = "parent_id"
        case link
        case createdAt = "create_at"
        case lastUpdatedAt = "last_updated_at"
        case customName = "custom_name"
        case pritority = "read_priority"
        
        var dataType: ColumnDataType {
            switch self {
            case .uid: return .text([.primaryKey(autoIncrement: false), .notNull])
            case .ownerID: return .text([])
            case .parentID: return .text([])
            case .link: return .text([.notNull])
            case .createdAt: return .real([.notNull])
            case .lastUpdatedAt: return .real([.notNull])
            case .customName: return .text([])
            case .pritority: return .integer([])
            }
        }
    }
}


extension ReadLinkTable.Entity {
    
    func asReadLink() -> ReadLink {
        let link = ReadLink(uid: self.uid, link: self.link,
                            createAt: self.createdAt, lastUpdated: self.lastUpdatedAt)
        return link
            |> \.ownerID .~ self.ownerID
            |> \.parentID .~ self.parentID
            |> \.customName .~ self.customName
            |> \.priority .~ self.priority
    }
}
