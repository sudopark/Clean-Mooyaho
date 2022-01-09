//
//  SuggestableQueryTable.swift
//  DataStore
//
//  Created by sudo.park on 2021/11/26.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import SQLiteService


struct SuggestableQueryTable: Table {
    
    struct Entity: RowValueType {
        
        let text: String
        
        init(_ text: String) {
            self.text = text
        }
        
        init(_ cursor: CursorIterator) throws {
            self.text = try cursor.next().unwrap()
        }
    }
    
    enum Columns: String, TableColumn {
        case queryText = "q_txt"
        
        var dataType: ColumnDataType {
            return .text([.primaryKey(autoIncrement: false)])
        }
    }
    
    static var tableName: String { "suggestable_queries" }
    typealias EntityType = Entity
    typealias ColumnType = Columns
    
    static func scalar(_ entity: EntityType, for column: ColumnType) -> ScalarType? {
        switch column {
        case .queryText: return entity.text
        }
    }
}
