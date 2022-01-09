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
        case .ownerID: return entity.ownerID
        case .parentID: return entity.parentID
        case .name: return entity.name
        case .description: return entity.collectionDescription
        case .createdAt: return entity.createdAt
        case .lastUpdatedAt: return entity.lastUpdatedAt
        case .pritority: return entity.priority?.rawValue
        case .categoryIDs: return try? entity.categoryIDs.asArrayText()
        case .remindTime: return entity.remindTime
        }
    }
}

extension ReadCollectionTable {
    
    struct Entity: RowValueType {
        
        let uid: String
        let ownerID: String?
        let parentID: String?
        let name: String
        let collectionDescription: String?
        let createdAt: TimeStamp
        let lastUpdatedAt: TimeStamp
        let priority: ReadPriority?
        let categoryIDs: [String]
        let remindTime: TimeStamp?
        
        init(_ cursor: CursorIterator) throws {
            self.uid = try cursor.next().unwrap()
            self.ownerID = cursor.next()
            self.parentID = cursor.next()
            self.name = try cursor.next().unwrap()
            self.collectionDescription = cursor.next()
            self.createdAt = try cursor.next().unwrap()
            self.lastUpdatedAt = try cursor.next().unwrap()
            self.priority = cursor.next().flatMap{ ReadPriority.init(rawValue: $0) }
            let idText: String = try cursor.next().unwrap()
            self.categoryIDs = try idText.toArray()
            self.remindTime = cursor.next()
        }
        
        init(collection: ReadCollection) {
            self.uid = collection.uid
            self.ownerID = collection.ownerID
            self.parentID = collection.parentID
            self.name = collection.name
            self.collectionDescription = collection.collectionDescription
            self.createdAt = collection.createdAt
            self.lastUpdatedAt = collection.lastUpdatedAt
            self.priority = collection.priority
            self.categoryIDs = collection.categoryIDs
            self.remindTime = collection.remindTime
        }
    }
}

extension ReadCollectionTable {
    
    enum Columns: String, TableColumn {
        case uid = "unq_id"
        case ownerID = "owner_id"
        case parentID = "parent_id"
        case name
        case description = "clc_desc"
        case createdAt = "create_at"
        case lastUpdatedAt = "last_updated_at"
        case pritority = "read_priority"
        case categoryIDs = "cate_ids"
        case remindTime = "remind_time"
        
        var dataType: ColumnDataType {
            switch self {
            case .uid: return .text([.primaryKey(autoIncrement: false), .notNull])
            case .ownerID: return .text([])
            case .parentID: return .text([])
            case .name: return .text([.notNull])
            case .description: return .text([])
            case .createdAt: return .real([.notNull])
            case .lastUpdatedAt: return .real([.notNull])
            case .pritority: return .integer([])
            case .categoryIDs: return .text([])
            case .remindTime: return .real([])
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
            |> \.collectionDescription .~ self.collectionDescription
            |> \.categoryIDs .~ self.categoryIDs
            |> \.remindTime .~ self.remindTime
    }
}
