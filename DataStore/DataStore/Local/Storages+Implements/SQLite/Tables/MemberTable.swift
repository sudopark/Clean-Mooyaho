//
//  MemberTable.swift
//  DataStore
//
//  Created by sudo.park on 2021/06/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import SQLiteService

import Domain
import Extensions


struct MemberTable: Table {
    
    struct Entity: RowValueType {
        let uid: String
        let nickName: String?
        let introduction: String?
        let deactivatedAt: TimeStamp?
        
        init(_ cursor: CursorIterator) throws {
            self.uid = try cursor.next().unwrap()
            self.nickName = cursor.next()
            self.introduction = cursor.next()
            self.deactivatedAt = cursor.next()
        }
        
        init(_ member: Member) {
            self.uid = member.uid
            self.nickName = member.nickName
            self.introduction = member.introduction
            self.deactivatedAt = member.deactivatedDateTimeStamp
        }
    }
    
    enum Column: String, TableColumn {
        case uid
        case nickName = "nikc_name"
        case intro
        case deactivatedAt = "deactivated_at"
        
        var dataType: ColumnDataType {
            switch self {
            case .uid: return .text([.primaryKey(autoIncrement: false), .notNull])
            case .nickName: return .text([])
            case .intro: return .text([])
            case .deactivatedAt: return .real([])
            }
        }
    }
    
    typealias EntityType = Entity
    typealias ColumnType = Column
    
    static var tableName: String { "members" }
    
    static func scalar(_ model: Entity, for column: Column) -> ScalarType? {
        switch column {
        case .uid: return model.uid
        case .nickName: return model.nickName
        case .intro: return model.introduction
        case .deactivatedAt: return model.deactivatedAt
        }
    }
}

