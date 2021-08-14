//
//  PlaceInfoTable.swift
//  DataStore
//
//  Created by sudo.park on 2021/07/11.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import SQLiteService

import Domain

struct PlaceInfoTable: Table {
    
    struct Entity: RowValueType {
        
        let uid: String
        let title: String
        let externalSearchID: String?
        let detailLink: String?
        let latt: Double
        let long: Double
        let address: String
        let contact: String?
        let categoryIDs: [String]
        let reporterID: String
        let infoProvider: Place.RequireInfoProvider
        let createAt: TimeStamp
        let placePickCount: Int
        let lastPickedAt: TimeStamp
        
        init(place: Place) {
            self.uid = place.uid
            self.title = place.title
            self.externalSearchID = place.externalSearchID
            self.detailLink = place.detailLink
            self.latt = place.coordinate.latt
            self.long = place.coordinate.long
            self.address = place.address
            self.contact = place.contact
            self.categoryIDs = place.placeCategoryTags.map{ $0.keyword }
            self.reporterID = place.reporterID
            self.infoProvider = place.requireInfoProvider
            self.createAt = place.createdAt
            self.placePickCount = place.placePickCount
            self.lastPickedAt = place.lastPickedAt
        }
        
        init(_ cursor: CursorIterator) throws {
            self.uid = try cursor.next().unwrap()
            self.title = try cursor.next().unwrap()
            self.externalSearchID = cursor.next()
            self.detailLink = cursor.next()
            self.latt = try cursor.next().unwrap()
            self.long = try cursor.next().unwrap()
            self.address = try cursor.next().unwrap()
            self.contact = cursor.next()
            let catIDsString: String = cursor.next() ?? ""
            self.categoryIDs = catIDsString.components(separatedBy: ",")
            self.reporterID = try cursor.next().unwrap()
            let infoRawValue: String = try cursor.next().unwrap()
            guard let provider = Place.RequireInfoProvider(rawValue: infoRawValue) else {
                throw LocalErrors.invalidData("Place.RequireInfoProvider")
            }
            self.infoProvider = provider
            self.createAt = try cursor.next().unwrap()
            self.placePickCount = try cursor.next().unwrap()
            self.lastPickedAt = try cursor.next().unwrap()
        }
    }
    
    enum Columns: String, TableColumn {
        case uid
        case title
        case externalSearchID = "external_seaerch_id"
        case link
        case latt
        case long
        case address
        case contact
        case categoryIDs = "cat_ids"
        case reporterID = "reporter_id"
        case infoProvider = "provider"
        case createAt = "created_at"
        case pickCount = "pick_count"
        case lastPickedAt = "last_picked_at"
        
        var dataType: ColumnDataType {
            switch self {
            case .uid: return .text([.primaryKey(autoIncrement: false), .notNull])
            case .title: return .text([.notNull])
            case .externalSearchID: return .text([])
            case .link: return .text([])
            case .latt, .long: return .real([.notNull])
            case .address: return .text([.notNull])
            case .contact: return .text([])
            case .categoryIDs: return .text([.default("")])
            case .reporterID: return .text([.notNull])
            case .infoProvider: return .text([.notNull])
            case .createAt: return .real([.notNull])
            case .pickCount: return .integer([.default(0)])
            case .lastPickedAt: return .real([.notNull])
            }
        }
    }
    
    static var tableName: String { "placeinfos" }
    typealias EntityType = Entity
    typealias ColumnType = Columns
    
    static func scalar(_ model: Entity, for column: Columns) -> ScalarType? {
        switch column {
        case .uid: return model.uid
        case .title: return model.title
        case .externalSearchID: return model.externalSearchID
        case .link: return model.detailLink
        case .latt: return model.latt
        case .long: return model.long
        case .address: return model.address
        case .contact: return model.contact
        case .categoryIDs: return model.categoryIDs.joined(separator: ",")
        case .reporterID: return model.reporterID
        case .infoProvider: return model.infoProvider.rawValue
        case .createAt: return model.createAt
        case .pickCount: return model.placePickCount
        case .lastPickedAt: return model.lastPickedAt
        }
    }
}


extension Place.RequireInfoProvider: RowValueType {
    
    public init(_ cursor: CursorIterator) throws {
        let rawValue: String = try cursor.next().unwrap()
        guard let provider = Place.RequireInfoProvider(rawValue: rawValue) else {
            throw LocalErrors.invalidData("RequireInfoProvider")
        }
        self = provider
    }
}
