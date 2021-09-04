//
//  HoorayAckUserTable.swift
//  DataStore
//
//  Created by sudo.park on 2021/08/27.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import Domain

import SQLiteService


struct HoorayAckUserTable: Table {
    
    struct Entity: RowValueType {
        
        let hoorayID: String
        let ackUserID: String
        let ackAt: TimeStamp
        
        init(_ cursor: CursorIterator) throws {
            self.hoorayID = try cursor.next().unwrap()
            self.ackUserID = try cursor.next().unwrap()
            self.ackAt = try cursor.next().unwrap()
        }
        
        init(_ ack: HoorayAckInfo) {
            self.hoorayID = ack.hoorayID
            self.ackUserID = ack.ackUserID
            self.ackAt = ack.ackAt
        }
    }
    
    enum Columns: String, TableColumn {
        case hoorayID = "hooray_id"
        case ackUserID = "ack_uid"
        case ackAt = "ack_at"
        
        var dataType: ColumnDataType {
            switch self {
            case .hoorayID: return .text([.primaryKey(autoIncrement: false), .notNull])
            case .ackUserID: return .text([.primaryKey(autoIncrement: false), .notNull])
            case .ackAt: return .real([.notNull])
            }
        }
    }
    
    typealias EntityType = Entity
    typealias ColumnType = Columns
    
    static var tableName: String { "hooray_acks" }
    
    static func scalar(_ entity: Entity, for column: Columns) -> ScalarType? {
        switch column {
        case .hoorayID: return entity.hoorayID
        case .ackUserID: return entity.ackUserID
        case .ackAt: return entity.ackAt
        }
    }
}
