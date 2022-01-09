//
//  ReadLinkMemoTable.swift
//  DataStore
//
//  Created by sudo.park on 2021/10/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import SQLiteService

import Domain


extension ReadLinkMemo: RowValueType {
    
    public init(_ cursor: CursorIterator) throws {
        self.init(itemID: try cursor.next().unwrap())
        self.content = cursor.next()
    }
}


struct ReadLinkMemoTable: Table {
    
    enum Columns: String, TableColumn {
        case itemID = "item_id"
        case content = "memo_content"
        
        var dataType: ColumnDataType {
            switch self {
            case .itemID: return .text([.primaryKey(autoIncrement: false), .notNull])
            case .content: return .text([])
            }
        }
    }
    
    typealias ColumnType = Columns
    typealias EntityType = ReadLinkMemo
    
    static var tableName: String { "link_memos" }
    
    static func scalar(_ entity: ReadLinkMemo, for column: Columns) -> ScalarType? {
        switch column {
        case .itemID: return entity.linkItemID
        case .content: return entity.content
        }
    }
}
