//
//  SharedReadCollectionTable.swift
//  DataStore
//
//  Created by sudo.park on 2021/11/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import SQLiteService
import Prelude
import Optics

import Domain



struct SharedRootReadCollectionTable: Table {
    
    struct Entity: RowValueType {
        let shareID: String
        let uid: String
        let name: String
        let description: String?
        let ownerID: String
        let parentID: String?
        let createdAt: TimeStamp
        let lastUpdatedAt: TimeStamp
        let categoryIDs: [String]
        let lastOpened: TimeStamp
        
        init(_ cursor: CursorIterator) throws {
            self.shareID = try cursor.next().unwrap()
            self.uid = try cursor.next().unwrap()
            self.name = try cursor.next().unwrap()
            self.description = cursor.next()
            self.ownerID = try cursor.next().unwrap()
            self.parentID = cursor.next()
            self.createdAt = try cursor.next().unwrap()
            self.lastUpdatedAt = try cursor.next().unwrap()
            let idText: String = try cursor.next().unwrap()
            self.categoryIDs = try idText.toArray()
            self.lastOpened = try cursor.next().unwrap()
        }
        
        init?(collection: SharedReadCollection) {
            guard let ownerID = collection.ownerID else { return nil }
            self.shareID = collection.shareID
            self.uid = collection.uid
            self.ownerID = ownerID
            self.parentID = collection.parentID
            self.name = collection.name
            self.description = collection.description
            self.createdAt = collection.createdAt
            self.lastUpdatedAt = collection.lastUpdatedAt
            self.categoryIDs = collection.categoryIDs
            self.lastOpened = .now()
        }
    }
    
    
    enum Columns: String, TableColumn {
        case shareID = "sid"
        case uid = "unq_id"
        case ownerID = "owner_id"
        case parentID = "parent_id"
        case name
        case description = "clc_desc"
        case createdAt = "create_at"
        case lastUpdatedAt = "last_updated_at"
        case categoryIDs = "cate_ids"
        case lastOpened = "last_opened_at"
        
        var dataType: ColumnDataType {
            switch self {
            case .shareID: return .text([.primaryKey(autoIncrement: false), .notNull])
            case .uid: return .text([.notNull])
            case .ownerID: return .text([.notNull])
            case .parentID: return .text([])
            case .name: return .text([.notNull])
            case .description: return .text([])
            case .createdAt: return .real([.notNull])
            case .lastUpdatedAt: return .real([.notNull])
            case .categoryIDs: return .text([])
            case .lastOpened: return .real([.notNull])
            }
        }
    }
    
    
    typealias EntityType = Entity
    typealias ColumnType = Columns
    
    static var tableName: String { "shared_collections" }
    
    
    static func scalar(_ entity: Entity, for column: Columns) -> ScalarType? {
        switch column {
        case .shareID: return entity.shareID
        case .uid: return entity.uid
        case .ownerID: return entity.ownerID
        case .parentID: return entity.parentID
        case .name: return entity.name
        case .description: return entity.description
        case .createdAt: return entity.createdAt
        case .lastUpdatedAt: return entity.lastUpdatedAt
        case .categoryIDs: return try? entity.categoryIDs.asArrayText()
        case .lastOpened: return entity.lastOpened
        }
    }
}


extension SharedRootReadCollectionTable.Entity {
    
    func asCollection() -> SharedReadCollection {
        let collection = SharedReadCollection(shareID: self.shareID,
                                              uid: self.uid,
                                              name: self.name,
                                              createdAt: self.createdAt,
                                              lastUpdated: self.lastUpdatedAt)
        
        return collection
            |> \.ownerID .~ self.ownerID
            |> \.parentID .~ self.parentID
            |> \.description .~ self.description
            |> \.categoryIDs .~ self.categoryIDs
    }
}
