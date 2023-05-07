//
//  FavoriteReadingListItemIDTable.swift
//  ReadingList
//
//  Created by sudo.park on 2022/08/15.
//

import Foundation
import SQLiteService


struct FavoriteReadingListItemIDTable: Table {
    
    typealias EntityType = Entity
    typealias ColumnType = Columns
    
    static var tableName: String { "favorite_itemids" }
    
    static func scalar(_ entity: Entity, for column: Columns) -> ScalarType? {
        switch column {
        case .itemID: return entity.id
        }
    }
}


extension FavoriteReadingListItemIDTable {
    
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
            switch self {
            case .itemID: return .text([.primaryKey(autoIncrement: false), .notNull])
            }
        }
    }
}
