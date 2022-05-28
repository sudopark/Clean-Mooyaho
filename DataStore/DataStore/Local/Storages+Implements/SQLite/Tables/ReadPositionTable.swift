//
//  ReadPositionTable.swift
//  DataStore
//
//  Created by sudo.park on 2022/05/28.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation

import SQLiteService

struct ReadPositionTable: Table {
    
    struct Entity: RowValueType {
        let itemID: String
        let position: Double?
        
        init(itemID: String, position: Double?) {
            self.itemID = itemID
            self.position = position
        }
        
        init(_ cursor: CursorIterator) throws {
            self.itemID = try cursor.next().unwrap()
            self.position = cursor.next()
        }
    }
    
    enum Columns: String, TableColumn {
        case itemID = "item_id"
        case position = "read_position"
        
        var dataType: ColumnDataType {
            switch self {
            case .itemID: return .text([.primaryKey(autoIncrement: false), .notNull])
            case .position: return .real([])
            }
        }
    }
    
    static var tableName: String = "read_positions"
    typealias EntityType = Entity
    typealias ColumnType = Columns
    
    static func scalar(_ entity: Entity, for column: Columns) -> ScalarType? {
        switch column {
        case .itemID: return entity.itemID
        case .position: return entity.position
        }
    }
}
