//
//  ReadPositionTable.swift
//  DataStore
//
//  Created by sudo.park on 2022/05/28.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation

import SQLiteService

import Domain


extension ReadPosition: RowValueType {
    
    public init(_ cursor: CursorIterator) throws {
        self.init(
            itemID: try cursor.next().unwrap(),
            position: try cursor.next().unwrap(),
            saved: try cursor.next().unwrap()
        )
    }
}

struct ReadPositionTable: Table {
    
    enum Columns: String, TableColumn {
        case itemID = "item_id"
        case position = "read_position"
        case saved = "saved_at"
        
        var dataType: ColumnDataType {
            switch self {
            case .itemID: return .text([.primaryKey(autoIncrement: false), .notNull])
            case .position: return .real([.notNull])
            case .saved: return .real([.notNull])
            }
        }
    }
    
    static var tableName: String = "read_positions"
    typealias EntityType = ReadPosition
    typealias ColumnType = Columns
    
    static func scalar(_ entity: ReadPosition, for column: Columns) -> ScalarType? {
        switch column {
        case .itemID: return entity.itemID
        case .position: return entity.position
        case .saved: return entity.saved
        }
    }
}
