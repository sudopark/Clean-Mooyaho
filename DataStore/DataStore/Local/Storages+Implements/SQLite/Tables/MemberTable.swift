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
        
        init(_ cursor: CursorIterator) throws {
            self.uid = try cursor.next().unwrap()
            self.nickName = cursor.next()
            self.introduction = cursor.next()
        }
        
        init(_ uid: String, nickName: String?, intro: String?) {
            self.uid = uid
            self.nickName = nickName
            self.introduction = intro
        }
    }
    
    enum Column: String, TableColumn {
        case uid
        case nickName = "nikc_name"
        case intro
        
        var dataType: ColumnDataType {
            switch self {
            case .uid: return .text([.primaryKey(autoIncrement: false), .notNull])
            case .nickName: return .text([])
            case .intro: return .text([])
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
        }
    }
}

