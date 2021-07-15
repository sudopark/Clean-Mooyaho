//
//  TagTable.swift
//  DataStore
//
//  Created by sudo.park on 2021/07/12.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import SQLiteService

import Domain


extension Tag: RowValueType {
    
    public init(_ cursor: CursorIterator) throws {
        let typeRawValue: String = try cursor.next().unwrap()
        guard let type = TagType(rawValue: typeRawValue) else {
            throw LocalErrors.deserializeFail("Tag.TagType")
        }
        let keyword: String = try cursor.next().unwrap()
        let emoji: String? = cursor.next()
        self.init(type: type, keyword: keyword, emoji: emoji)
    }
}

struct TagTable: Table {
    
    enum Columns: String, TableColumn {
        case type
        case keyword
        case emoji
        
        var dataType: ColumnDataType {
            switch self {
            case .type: return .text([.notNull])
            case .keyword: return .text([.notNull])
            case .emoji: return .text([])
            }
        }
    }
    
    static var tableName: String {
        return "tags"
    }
    
    typealias Model = Tag
    typealias ColumnType = Columns
    
    static func scalar(_ model: Tag, for column: Columns) -> ScalarType? {
        switch column {
        case .type: return model.tagType.rawValue
        case .keyword: return model.keyword
        case .emoji: return model.emoji
        }
    }
}
