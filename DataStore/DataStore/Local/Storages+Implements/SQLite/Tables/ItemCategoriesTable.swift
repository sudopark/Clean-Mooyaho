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

struct ItemCategoriesTable: Table {
    
    struct Entity: RowValueType {
        let itemID: String
        let cate: ItemCategory
        
        init(_ cursor: CursorIterator) throws {
            self.itemID = try cursor.next().unwrap()
            self.cate = .init(name: try cursor.next().unwrap(),
                              colorCode: try cursor.next().unwrap())
        }
        
        init(_ itemID: String, category: ItemCategory) {
            self.itemID = itemID
            self.cate = category
        }
    }
    
    enum Columns: String, TableColumn {
        case itemID
        case name
        case colorCode
        
        var dataType: ColumnDataType {
            switch self {
            case .itemID: return .text([.notNull])
            case .name: return .text([.notNull])
            case .colorCode: return .text([.notNull])
            }
        }
    }
    
    typealias EntityType = Entity
    typealias ColumnType = Columns
    
    static var tableName: String { "item_cates" }
    
    static func scalar(_ entity: EntityType, for column: Columns) -> ScalarType? {
        switch column {
        case .itemID: return entity.itemID
        case .name: return entity.cate.name
        case .colorCode: return entity.cate.colorCode
        }
    }
}
