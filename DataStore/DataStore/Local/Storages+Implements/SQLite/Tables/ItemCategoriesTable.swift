//
//  ItemCategoriesTable.swift
//  DataStore
//
//  Created by sudo.park on 2021/09/18.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import SQLiteService

import Domain


extension ItemCategory: RowValueType {
    
    public init(_ cursor: CursorIterator) throws {
        self.init(uid: try cursor.next().unwrap(),
                  name: try cursor.next().unwrap(),
                  colorCode: try cursor.next().unwrap())
    }
}

struct ItemCategoriesTable: Table {
    
    enum Columns: String, TableColumn {
        case itemID
        case name
        case colorCode
        
        var dataType: ColumnDataType {
            switch self {
            case .itemID: return .text([.primaryKey(autoIncrement: false), .notNull])
            case .name: return .text([.notNull])
            case .colorCode: return .text([.notNull])
            }
        }
    }
    
    typealias EntityType = ItemCategory
    typealias ColumnType = Columns
    
    static var tableName: String { "item_cates" }
    
    static func scalar(_ entity: EntityType, for column: Columns) -> ScalarType? {
        switch column {
        case .itemID: return entity.uid
        case .name: return entity.name
        case .colorCode: return entity.colorCode
        }
    }
}
