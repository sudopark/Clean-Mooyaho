//
//  ReadingListItemCategoryTable.swift
//  ReadingList
//
//  Created by sudo.park on 2022/08/24.
//

import Foundation

import SQLiteService
import Domain

extension ReadingListItemCategory: RowValueType {
    
    public init(_ cursor: CursorIterator) throws {
        self.init(
            uid: try cursor.next().unwrap(),
            name: try cursor.next().unwrap(),
            colorCode: try cursor.next().unwrap(),
            createdAt: try cursor.next().unwrap()
        )
    }
}


struct ReadingListItemCategoryTable: Table {
    
    enum Columns: String, TableColumn {
        case itemID
        case name
        case colorCode
        case createAt = "created_at"
        
        var dataType: ColumnDataType {
            switch self {
            case .itemID: return .text([.primaryKey(autoIncrement: false), .notNull])
            case .name: return .text([.notNull])
            case .colorCode: return .text([.notNull])
            case .createAt: return .real([.notNull])
            }
        }
    }
    
    typealias EntityType = ReadingListItemCategory
    typealias ColumnType = Columns
    
    static var tableName: String { "item_cates" }
    
    static func scalar(_ entity: ReadingListItemCategory, for column: Columns) -> ScalarType? {
        switch column {
        case .itemID: return entity.uid
        case .name: return entity.name
        case .colorCode: return entity.colorCode
        case .createAt: return entity.createdAt
        }
    }
}
