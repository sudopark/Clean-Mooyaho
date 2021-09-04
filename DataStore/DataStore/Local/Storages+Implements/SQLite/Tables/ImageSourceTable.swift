//
//  ImageSourceTable.swift
//  DataStore
//
//  Created by sudo.park on 2021/06/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import SQLiteService

import Domain


// MARK: - ImageSource as RowValueType

extension ImageSource: RowValueType {
    
    public init(_ cursor: CursorIterator) throws {
        let path: String = try cursor.next().unwrap()
        if let width: Double = try? cursor.next().unwrap(),
           let height: Double = try? cursor.next().unwrap() {
            self.init(path: path, size: .init(width, height))
        } else {
            self.init(path: path, size: nil)
        }
    }
}


// MARK: - ImageSourceTable

struct ImageSourceTable: Table {
    
    struct Entity: RowValueType {
        let ownerID: String
        let source: ImageSource?
        
        init(_ cursor: CursorIterator) throws {
            self.ownerID = try cursor.next().unwrap()
            self.source = try? ImageSource(cursor)
        }
        
        init(_ ownerID: String, source: ImageSource?) {
            self.ownerID = ownerID
            self.source = source
        }
    }

    enum Column: String, TableColumn {
        case ownerID = "owner_id"
        case path
        case width
        case height
        
        var dataType: ColumnDataType {
            switch self {
            case .ownerID: return .text([.primaryKey(autoIncrement: false), .notNull])
            case .path: return .text([])
            case .width: return .real([])
            case .height: return .real([])
            }
        }
    }
    
    typealias EntityType = Entity
    typealias ColumnType = Column
    
    static var tableName: String { "image_sources" }
    
    static func scalar(_ entity: Entity, for column: Column) -> ScalarType? {
        switch column {
        case .ownerID: return entity.ownerID
        case .path: return entity.source?.path
        case .width: return entity.source?.size?.width
        case .height: return entity.source?.size?.height
        }
    }
}
