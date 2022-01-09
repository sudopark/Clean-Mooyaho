//
//  LinkPreviewTable.swift
//  DataStore
//
//  Created by sudo.park on 2021/09/26.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import SQLiteService

import Domain


extension LinkPreview: RowValueType {
    
    public init(_ cursor: CursorIterator) throws {
        self.init(title: cursor.next(),
                  description: cursor.next(),
                  mainImageURL: cursor.next(),
                  iconURL: cursor.next())
    }
    
}

struct LinkPreviewTable: Table {
    
    struct Entity: RowValueType {
        let url: String
        let preview: LinkPreview
        
        init(_ cursor: CursorIterator) throws {
            self.url = try cursor.next().unwrap()
            self.preview = try LinkPreview(cursor)
        }
        
        init(url: String, preview: LinkPreview) {
            self.url = url
            self.preview = preview
        }
    }
    
    enum Columns: String, TableColumn {
        case url
        case title
        case description
        case mainImageUrl = "main_image_url"
        case iconURL = "icon_url"
        
        var dataType: ColumnDataType {
            switch self {
            case .url: return .text([.primaryKey(autoIncrement: false), .notNull])
            default: return .text([])
            }
        }
    }
    
    typealias EntityType = Entity
    typealias ColumnType = Columns
    static var tableName: String { "link_previews" }
    
    static func scalar(_ entity: Entity, for column: Columns) -> ScalarType? {
        switch column {
        case .url: return entity.url
        case .title: return entity.preview.title
        case .description: return entity.preview.description
        case .mainImageUrl: return entity.preview.mainImageURL
        case .iconURL: return entity.preview.iconURL
        }
    }
}
