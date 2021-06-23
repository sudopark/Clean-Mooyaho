//
//  ImageSourceTable.swift
//  DataStore
//
//  Created by sudo.park on 2021/06/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import SQLiteStorage

import Domain


// MARK: - ImageSource as RowValueType

extension ImageSource: RowValueType {
    
    public init(_ cursor: CursorIterator) throws {
        let type: String = try cursor.next().unwrap()
        switch type {
        case "path":
            self = .path(try cursor.next().unwrap())
            
        case "reference":
            self = .reference(try cursor.next().unwrap(), description: cursor.next())
            
        case "emoji":
            self = .emoji(try cursor.next().unwrap())
            
        default: throw LocalErrors.invalidData("ImageSource")
        }
    }
}


// MARK: - ImageSourceTable

struct ImageSourceTable: Table {
    
    struct DataModel: RowValueType {
        let ownerID: String
        let source: ImageSource
        
        init(_ cursor: CursorIterator) throws {
            self.ownerID = try cursor.next().unwrap()
            self.source = try ImageSource(cursor)
        }
    }

    enum Column: String, TableColumn {
        case ownerID = "owner_id"
        case sourcetype = "source_type"
        case path
        case description
        case emoji
        
        var dataType: ColumnDataType {
            switch self {
            case .ownerID: return .text([.primaryKey(autoIncrement: false), .notNull])
            case .sourcetype: return .text([.unique, .notNull])
            case .path, .description, .emoji: return .text([])
            }
        }
    }
    
    typealias Model = DataModel
    typealias ColumnType = Column
    
    static var tableName: String { "image_sources" }
    
    static func scalar(_ model: DataModel, for column: Column) -> ScalarType? {
        switch column {
        case .ownerID: return model.ownerID
        case .sourcetype: return model.source.type
        case .path: return model.source.path
        case .description: return model.source.description
        case .emoji: return model.source.emoji
        }
    }
}


private extension ImageSource {
    
    var type: String {
        switch self {
        case .path: return "path"
        case .reference: return "reference"
        case .emoji: return "emoji"
        }
    }
    
    var path: String? {
        switch self {
        case let .path(value),
             let .reference(value, _): return value
        default: return nil
        }
    }
    
    var description: String? {
        guard case let .reference(_, value) = self else { return nil }
        return value
    }
    
    var emoji: String? {
        guard case let .emoji(value) = self else { return nil }
        return value
    }
}
