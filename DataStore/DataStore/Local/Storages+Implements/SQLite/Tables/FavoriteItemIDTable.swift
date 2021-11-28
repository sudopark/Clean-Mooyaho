//
//  FavoriteItemIDTable.swift
//  DataStore
//
//  Created by sudo.park on 2021/11/28.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import SQLiteService


struct FavoriteItemIDTable: Table {
    
    struct Entity: RowValueType {
        let id: String
        
        init(id: String) { self.id = id }
        
        init(_ cursor: CursorIterator) throws {
            self.id = try cursor.next().unwrap()
        }
    }
    
    enum Columns: String, TableColumn {
        case itemID = "item_id"
        
        var dataType: ColumnDataType {
            return .text([.primaryKey(autoIncrement: false), .notNull])
        }
    }
    
    typealias EntityType = Entity
    typealias ColumnType = Columns
    
    static var tableName: String { "favorite_itemids" }
    
    static func scalar(_ entity: Entity, for column: Columns) -> ScalarType? {
        return entity.id
    }
}
