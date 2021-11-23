//
//  LatestSearchQueryTable.swift
//  DataStore
//
//  Created by sudo.park on 2021/11/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import SQLiteService

import Domain


extension LatestSearchedQuery: RowValueType {
    
    public init(_ cursor: CursorIterator) throws {
        self.init(text: try cursor.next().unwrap(),
                  time: try cursor.next().unwrap())
    }
}

struct LatestSearchQueryTable: Table {
    
    enum Columns: String, TableColumn {
        case query = "qry"
        case time = "ts"
        
        var dataType: ColumnDataType {
            switch self {
            case .query: return .text([.primaryKey(autoIncrement: false), .notNull])
            case .time: return .real([.notNull])
            }
        }
    }
    
    typealias ColumnType = Columns
    typealias EntityType = LatestSearchedQuery
    
    static var tableName: String = "latest_search_queries"
    
    static func scalar(_ entity: LatestSearchedQuery, for column: Columns) -> ScalarType? {
        switch column {
        case .query: return entity.text
        case .time: return entity.searchedTime
        }
    }
}
