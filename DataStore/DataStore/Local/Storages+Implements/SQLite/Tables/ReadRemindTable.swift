//
//  ReadRemindTable.swift
//  DataStore
//
//  Created by sudo.park on 2021/10/23.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import SQLiteService

import Domain


extension ReadRemind: RowValueType {
    
    public init(_ cursor: CursorIterator) throws {
        self.init(uid: try cursor.next().unwrap(),
                  itemID: try cursor.next().unwrap(),
                  scheduledTime: try cursor.next().unwrap())
    }
}


struct ReadRemindTable: Table {
    
    enum Columns: String, TableColumn {
        case uid
        case itemID = "item_id"
        case scheduleTime = "schedule_time"
        
        var dataType: ColumnDataType {
            switch self {
            case .uid: return .text([.primaryKey(autoIncrement: false), .notNull])
            case .itemID: return .text([.notNull])
            case .scheduleTime: return .real([.notNull])
            }
        }
    }
    
    typealias ColumnType = Columns
    typealias EntityType = ReadRemind
    
    static var tableName: String { "read_reminds" }
    
    static func scalar(_ entity: ReadRemind, for column: Columns) -> ScalarType? {
        switch column {
        case .uid: return entity.uid
        case .itemID: return entity.itemID
        case .scheduleTime: return entity.scheduledTime
        }
    }
}
