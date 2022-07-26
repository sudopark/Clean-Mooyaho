//
//  ReadLinkItemTable.swift
//  ReadingList
//
//  Created by sudo.park on 2022/07/20.
//

import Foundation

import Domain
import Extensions
import SQLiteService
import Prelude
import Optics


struct ReadLinkItemTable: Table {
    
    typealias EntityType = Entity
    typealias ColumnType = Columns
    
    static var tableName: String { "read_links" }
    
    static func scalar(_ entity: Entity, for column: Columns) -> ScalarType? {
        switch column {
        case .uid: return entity.uid
        case .ownerID: return entity.ownerID
        case .parentID: return entity.parentID
        case .link: return entity.link
        case .createdAt: return entity.createdAt
        case .lastUpdatedAt: return entity.lastUpdatedAt
        case .customName: return entity.customName
        case .pritority: return entity.priorityID
        case .categoryIDs: return try? entity.categoryIDs.asArrayText()
        case .remindTime: return nil
        case .isRed: return entity.isRed
        }
    }
}


// MARK: - entity and columns

extension ReadLinkItemTable {
    
    struct Entity: RowValueType {
        
        let uid: String
        let ownerID: String?
        let parentID: String?
        let link: String
        let createdAt: TimeStamp
        let lastUpdatedAt: TimeStamp
        let customName: String?
        let priorityID: Int?
        let categoryIDs: [String]
        let isRed: Bool
        
        init(_ cursor: CursorIterator) throws {
            self.uid = try cursor.next().unwrap()
            self.ownerID = cursor.next()
            self.parentID = cursor.next()
            self.link = try cursor.next().unwrap()
            self.createdAt = try cursor.next().unwrap()
            self.lastUpdatedAt = try cursor.next().unwrap()
            self.customName = cursor.next()
            self.priorityID = cursor.next()
            let idText: String = try cursor.next().unwrap()
            self.categoryIDs = try idText.toArray()
            // remind  정보는 제외되었지만 interation을 하기위해 필요?
            let _ : TimeStamp? = cursor.next()
            self.isRed = try cursor.next().unwrap()
        }
        
        init(item: ReadLinkItem, parentID: String?) {
            self.uid = item.uuid
            self.ownerID = item.ownerID
            self.parentID = parentID
            self.link = item.link
            self.createdAt = item.createdAt
            self.lastUpdatedAt = item.lastUpdatedAt
            self.customName = item.customName
            self.priorityID = item.priorityID
            self.categoryIDs = item.categoryIds
            self.isRed = item.isRead
        }
    }
    
    enum Columns: String, TableColumn {
        
        case uid
        case ownerID = "owner_id"
        case parentID = "parent_id"
        case link
        case createdAt = "create_at"
        case lastUpdatedAt = "last_updated_at"
        case customName = "custom_name"
        case pritority = "read_priority"
        case categoryIDs = "cate_ids"
        case remindTime = "remind_time"
        case isRed = "is_red"
        
        var dataType: ColumnDataType {
            switch self {
            case .uid: return .text([.primaryKey(autoIncrement: false), .notNull])
            case .ownerID: return .text([])
            case .parentID: return .text([])
            case .link: return .text([.notNull])
            case .createdAt: return .real([.notNull])
            case .lastUpdatedAt: return .real([.notNull])
            case .customName: return .text([])
            case .pritority: return .integer([])
            case .categoryIDs: return .text([])
            case .remindTime: return .real([])
            case .isRed: return .integer([.default(0)])
            }
        }
    }
}


extension ReadLinkItemTable.Entity {
    
    func asLinkItem() -> ReadLinkItem {
        return .init(uuid: self.uid, link: self.link, createAt: self.createdAt, lastUpdatedAt: self.lastUpdatedAt)
            |> \.customName .~ self.customName
            |> \.priorityID .~ self.priorityID
            |> \.categoryIds .~ self.categoryIDs
            |> \.isRead .~ self.isRed
    }
}
