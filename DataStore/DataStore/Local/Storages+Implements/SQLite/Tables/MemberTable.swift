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


struct MemberTable: Table {
    
    struct Entity: RowValueType {
        let uid: String
        let nickName: String?
        let introduction: String?
        let isDeactivated: Bool
        
        init(_ cursor: CursorIterator) throws {
            self.uid = try cursor.next().unwrap()
            self.nickName = cursor.next()
            self.introduction = cursor.next()
            self.isDeactivated = (try? cursor.next().unwrap()) ?? false
        }
        
        init(_ member: Member) {
            self.uid = member.uid
            self.nickName = member.nickName
            self.introduction = member.introduction
            self.isDeactivated = member.isDeactivated
        }
    }
    
    enum Column: String, TableColumn {
        case uid
        case nickName = "nikc_name"
        case intro
        case isDeactivated
        
        var dataType: ColumnDataType {
            switch self {
            case .uid: return .text([.primaryKey(autoIncrement: false), .notNull])
            case .nickName: return .text([])
            case .intro: return .text([])
            case .isDeactivated: return .integer([])
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
        case .isDeactivated: return model.isDeactivated
        }
    }
}

