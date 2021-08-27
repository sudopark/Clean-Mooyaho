//
//  HoorayReactionsTable.swift
//  DataStore
//
//  Created by sudo.park on 2021/08/27.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import SQLiteService

import Domain


struct HoorayReactionTable: Table {
    
    
    struct Entity: RowValueType {
        let reactionID: String
        let hoorayID: String
        let memberID: String
        let reactAt: TimeStamp
        
        init(_ cursor: CursorIterator) throws {
            self.reactionID = try cursor.next().unwrap()
            self.hoorayID = try cursor.next().unwrap()
            self.memberID = try cursor.next().unwrap()
            self.reactAt = try cursor.next().unwrap()
        }
        
        init(_ hoorayID: String, info: HoorayReaction.ReactionInfo) {
            self.reactionID = info.reactionID
            self.hoorayID = hoorayID
            self.memberID = info.reactMemberID
            self.reactAt = info.reactAt
        }
    }
    
    enum Colums: String, TableColumn {
        case reactionID = "rid"
        case hoorayID = "hid"
        case memberID = "mid"
        case reactAt = "react_at"
        
        var dataType: ColumnDataType {
            switch self {
            case .reactionID: return .text([.primaryKey(autoIncrement: false), .notNull])
            case .hoorayID: return .text([.notNull])
            case .memberID: return .text([.notNull])
            case .reactAt: return .real([.notNull])
            }
        }
    }
    
    typealias EntityType = Entity
    typealias ColumnType = Colums
    
    static var tableName: String { "hooray_reactions" }
    
    static func scalar(_ entity: EntityType, for column: ColumnType) -> ScalarType? {
        switch column {
        case .reactionID: return entity.reactionID
        case .memberID: return entity.memberID
        case .hoorayID: return entity.hoorayID
        case .reactAt: return entity.reactAt
        }
    }
}
