//
//  SharingCollectionIDsTable.swift
//  DataStore
//
//  Created by sudo.park on 2021/11/15.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import SQLiteService


struct SharingCollectionIDsTable: Table {
    
    enum Columns: String, TableColumn {
        case collectionID = "cid"
        
        var dataType: ColumnDataType {
            return .text([.notNull])
        }
    }
    
    struct Entity: RowValueType {
        let collectionID: String
        
        init(_ id: String) {
            self.collectionID = id
        }
        
        init(_ cursor: CursorIterator) throws {
            self.collectionID = try cursor.next().unwrap()
        }
    }
    
    typealias EntityType = Entity
    typealias ColumnType = Columns
    static var tableName: String { "sharing_collection_ids" }
    
    static func scalar(_ entity: EntityType, for column: ColumnType) -> ScalarType? {
        switch column {
        case .collectionID: return entity.collectionID
        }
    }
}
