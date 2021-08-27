//
//  HoorayTable.swift
//  DataStore
//
//  Created by sudo.park on 2021/08/27.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import SQLiteService

import Domain


struct HoorayTable: Table {
    
     
    struct Entity: RowValueType {
        let uid: String
        let placeID: String?
        let publisherID: String
        let keyword: String
        let message: String
        let tags: [String]
        let coordinate: Coordinate
        let timeStamp: TimeStamp
        
        let spreadDistance: Meters
        let aliveTime: TimeInterval
        
        init(_ cursor: CursorIterator) throws {
            self.uid = try cursor.next().unwrap()
            self.placeID = cursor.next()
            self.publisherID = try cursor.next().unwrap()
            self.keyword = try cursor.next().unwrap()
            self.message = try cursor.next().unwrap()
            if let tagTexts: String = cursor.next() {
                self.tags = tagTexts.asStringArray()
            } else {
                self.tags = []
            }
            self.coordinate = .init(latt: try cursor.next().unwrap(), long: try cursor.next().unwrap())
            self.timeStamp = try cursor.next().unwrap()
            self.spreadDistance = try cursor.next().unwrap()
            self.aliveTime = try cursor.next().unwrap()
        }
        
        init(_ hooray: Hooray) {
            self.uid = hooray.uid
            self.placeID = hooray.placeID
            self.publisherID = hooray.publisherID
            self.keyword = hooray.hoorayKeyword
            self.message = hooray.message
            self.tags = hooray.tags
            self.coordinate = hooray.location
            self.timeStamp = hooray.timeStamp
            self.spreadDistance = hooray.spreadDistance
            self.aliveTime = hooray.aliveDuration
        }
    }
    
    enum Columns: String, TableColumn {
        case uid
        case placeID = "place_id"
        case publisherID = "pub_id"
        case keyword = "kwd"
        case message
        case tags
        case latt
        case long
        case timeStamp = "ts"
        case spreadDistance = "spr_dist"
        case aliveTime = "alv_dur"
        
        var dataType: ColumnDataType {
            switch self {
            case .uid: return .text([.primaryKey(autoIncrement: false), .notNull])
            case .placeID: return .text([])
            case .publisherID: return .text([.notNull])
            case .keyword: return .text([.notNull])
            case .message: return .text([.notNull])
            case .tags: return .text([])
            case .latt, .long: return .real([.notNull])
            case .timeStamp: return .real([.notNull])
            case .spreadDistance: return .real([.notNull])
            case .aliveTime: return .real([.notNull])
            }
        }
    }
    
    typealias EntityType = Entity
    typealias ColumnType = Columns
    
    static var tableName: String { "hoorays" }
    
    static func scalar(_ entity: Entity, for column: Columns) -> ScalarType? {
        switch column {
        case .uid: return entity.uid
        case .placeID: return entity.placeID
        case .publisherID: return entity.publisherID
        case .keyword: return entity.keyword
        case .message: return entity.message
        case .tags: return entity.tags.asDataText()
        case .latt: return entity.coordinate.latt
        case .long: return entity.coordinate.long
        case .timeStamp: return entity.timeStamp
        case .spreadDistance: return entity.spreadDistance
        case .aliveTime: return entity.aliveTime
        }
    }
}

private extension Array where Element == String {
    
    func asDataText() -> String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}


private extension String {
    
    func asStringArray() -> [String] {
        guard let data = self.data(using: .utf8) else {
            return []
        }
        return (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }
}
