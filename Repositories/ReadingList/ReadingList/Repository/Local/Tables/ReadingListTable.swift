//
//  ReadingListTable.swift
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


struct ReadingListTable: Table {
    
    typealias EntityType = Entity
    typealias ColumnType = Columns
    
    static var tableName: String { "read_collections" }
    
    static func scalar(_ entity: Entity, for column: Columns) -> ScalarType? {
        switch column {
        case .uid: return entity.uid
        case .ownerID: return entity.ownerID
        case .parentID: return entity.parentID
        case .name: return entity.name
        case .description: return entity.collectionDescription
        case .createdAt: return entity.createdAt
        case .lastUpdatedAt: return entity.lastUpdatedAt
        case .pritority: return entity.priorityID
        case .categoryIDs: return try? entity.categoryIDs.asArrayText()
        case .remindTime: return nil
        }
    }
}


// MARK: - entity and columns

extension ReadingListTable {
    
    struct Entity: RowValueType {
        
        let uid: String
        let ownerID: String?
        let parentID: String?
        let name: String
        let collectionDescription: String?
        let createdAt: TimeStamp
        let lastUpdatedAt: TimeStamp
        let priorityID: Int?
        let categoryIDs: [String]
        
        init(_ cursor: CursorIterator) throws {
            self.uid = try cursor.next().unwrap()
            self.ownerID = cursor.next()
            self.parentID = cursor.next()
            self.name = try cursor.next().unwrap()
            self.collectionDescription = cursor.next()
            self.createdAt = try cursor.next().unwrap()
            self.lastUpdatedAt = try cursor.next().unwrap()
            self.priorityID = cursor.next()
            let idText: String = try cursor.next().unwrap()
            self.categoryIDs = try idText.toArray()
            
            // remind  정보는 제외되었지만 interation을 하기위해 필요?
            let _ : TimeStamp? = cursor.next()
        }
        
        init(list: ReadingList, parentID: String?) {
            self.uid = list.uuid
            self.ownerID = list.ownerID
            self.parentID = parentID
            self.name = list.name
            self.collectionDescription = list.description
            self.createdAt = list.createdAt
            self.lastUpdatedAt = list.lastUpdatedAt
            self.priorityID = list.priorityID
            self.categoryIDs = list.categoryIds
        }
    }
    
    enum Columns: String, TableColumn {
        case uid = "unq_id"
        case ownerID = "owner_id"
        case parentID = "parent_id"
        case name
        case description = "clc_desc"
        case createdAt = "create_at"
        case lastUpdatedAt = "last_updated_at"
        case pritority = "read_priority"
        case categoryIDs = "cate_ids"
        case remindTime = "remind_time"
        
        var dataType: ColumnDataType {
            switch self {
            case .uid: return .text([.primaryKey(autoIncrement: false), .notNull])
            case .ownerID: return .text([])
            case .parentID: return .text([])
            case .name: return .text([.notNull])
            case .description: return .text([])
            case .createdAt: return .real([.notNull])
            case .lastUpdatedAt: return .real([.notNull])
            case .pritority: return .integer([])
            case .categoryIDs: return .text([])
            case .remindTime: return .real([])
            }
        }
    }
}


extension ReadingListTable.Entity {
    
    func asList() -> ReadingList {
        return .init(uuid: self.uid, name: self.name, isRootList: self.parentID == nil)
        |> \.ownerID .~ self.ownerID
        |> \.description .~ self.collectionDescription
        |> \.priorityID .~ self.priorityID
        |> \.categoryIds .~ self.categoryIDs
    }
}
