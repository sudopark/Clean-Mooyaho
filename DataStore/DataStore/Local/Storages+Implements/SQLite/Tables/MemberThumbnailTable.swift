//
//  MemberThumbnailTable.swift
//  DataStore
//
//  Created by sudo.park on 2021/09/04.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import SQLiteService

import Domain


struct ThumbnailTable: Table {
    
    struct Entity: RowValueType {
        let ownerID: String
        let thumbnail: Thumbnail?
        
        init(_ cursor: CursorIterator) throws {
            let ownerID: String = try cursor.next().unwrap()
            let isEmoji: Bool = try cursor.next().unwrap()
            let path: String? = cursor.next()
            let width: Double? = cursor.next()
            let height: Double? = cursor.next()
            if isEmoji  {
                self.init(ownerID, thumbnail: .emoji(try cursor.next().unwrap()))
            } else {
                let source = ImageSource(path: try path.unwrap(),
                                         size: .init(try width.unwrap(), try height.unwrap()))
                self.init(ownerID, thumbnail: .imageSource(source))
            }
        }
        
        init(_ ownerID: String, thumbnail: MemberThumbnail) {
            self.ownerID = ownerID
            self.thumbnail = thumbnail
        }
    }
    
    enum Columns: String, TableColumn {
        case ownerID = "owner_id"
        case isEmoji = "is_emoji"
        case path
        case width
        case height
        case emoji
        
        var dataType: ColumnDataType {
            switch self {
            case .ownerID: return .text([.primaryKey(autoIncrement: false), .notNull])
            case .isEmoji: return .integer([])
            case .path: return .text([])
            case .width, .height: return .real([])
            case .emoji: return .text([])
            }
        }
    }
    
    typealias ColumnType = Columns
    typealias EntityType = Entity
    
    static var tableName: String { "thumbnails" }
    
    static func scalar(_ entity: Entity, for column: Columns) -> ScalarType? {
        switch column {
        case .ownerID: return entity.ownerID
        case .isEmoji: return entity.thumbnail?.isEmoji
        case .path: return entity.thumbnail?.source?.path
        case .width: return entity.thumbnail?.source?.size?.width
        case .height: return entity.thumbnail?.source?.size?.height
        case .emoji: return entity.thumbnail?.emoji
        }
    }
}

extension MemberThumbnail {
    
    var isEmoji: Bool {
        guard case .emoji = self else { return false }
        return true
    }
    
    var source: ImageSource? {
        guard case let .imageSource(source) = self else { return nil }
        return source
    }
    
    var emoji: String? {
        guard case let .emoji(value) = self else { return nil }
        return value
    }
}
