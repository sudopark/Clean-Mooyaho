//
//  ReadCollectionTable.swift
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

struct ReadCollectionTable: Table {
    
    typealias EntityType = Entity
    typealias ColumnType = Columns
    
    static var tableName: String { "read_collections" }
    
    static func scalar(_ entity: Entity, for column: Columns) -> ScalarType? {
        switch column {
        case .uid: return entity.uid
        case .ownerID: return entity.parentID
        case .parentID: return entity.parentID
        case .name: return entity.name
        case .createdAt: return entity.createdAt
        case .lastUpdatedAt: return entity.lastUpdatedAt
        case .pritority: return entity.priority?.rawValue
        }
    }
}

extension ReadCollectionTable {
    
    struct Entity: RowValueType {
        
        let uid: String
        let ownerID: String?
        let parentID: String?
        let name: String
        let createdAt: TimeStamp
        let lastUpdatedAt: TimeStamp
        let priority: ReadPriority?
        
        init(_ cursor: CursorIterator) throws {
            self.uid = try cursor.next().unwrap()
            self.ownerID = cursor.next()
            self.parentID = cursor.next()
            self.name = try cursor.next().unwrap()
            self.createdAt = try cursor.next().unwrap()
            self.lastUpdatedAt = try cursor.next().unwrap()
            self.priority = cursor.next().flatMap{ ReadPriority.init(rawValue: $0) }
        }
        
        init(collection: ReadCollection) {
            self.uid = collection.uid
            self.ownerID = collection.ownerID
            self.parentID = collection.parentID
            self.name = collection.name
            self.createdAt = collection.createdAt
            self.lastUpdatedAt = collection.lastUpdatedAt
            self.priority = collection.priority
        }
    }
}

extension ReadCollectionTable {
    
    enum Columns: String, TableColumn {
        case uid = "unq_id"
        case ownerID = "owner_id"
        case parentID = "parent_id"
        case name
        case createdAt = "create_at"
        case lastUpdatedAt = "last_updated_at"
        case pritority = "read_priority"
        
        var dataType: ColumnDataType {
            switch self {
            case .uid: return .text([.primaryKey(autoIncrement: false), .notNull])
            case .ownerID: return .text([])
            case .parentID: return .text([])
            case .name: return .text([.notNull])
            case .createdAt: return .real([.notNull])
            case .lastUpdatedAt: return .real([.notNull])
            case .pritority: return .integer([])
            }
        }
    }
}


extension ReadCollectionTable.Entity {
    
    func asCollection() -> ReadCollection {
        let collection = ReadCollection(uid: self.uid, name: self.name,
                                        createdAt: self.createdAt, lastUpdated: self.lastUpdatedAt)
        return collection
            |> \.ownerID .~ self.ownerID
            |> \.parentID .~ self.parentID
            |> \.priority .~ self.priority
    }
}
