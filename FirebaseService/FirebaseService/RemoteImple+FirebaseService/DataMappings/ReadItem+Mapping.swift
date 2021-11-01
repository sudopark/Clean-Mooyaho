//
//  ReadItem+Mapping.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/11/01.
//

import Foundation

import Domain


enum ReadItemMappingKey: String, JSONMappingKeys {
    
    case uid
    case ownerID = "oid"
    case parentID = "pid"
    case createdAt = "crt_at"
    case lastUpdatedAt = "lst_up_at"
    case priority
    case remindTime = "rmt"
    case categoryIDs = "cate_ids"
    
    // key for collection
    case name = "nm"
    case collectionDescription = "cllc_desc"
    
    // key for link item
    case link
    case customName = "custom_nm"
    case isRed = "is_red"
    
    // key for option
    case customOrders = "custom_ords"
}

private typealias Key = ReadItemMappingKey

// MARK: - ReadCollection + Mapping

extension ReadCollection: DocumentMappable {
    
    init?(docuID: String, json: JSON) {
        guard let name = json[Key.name] as? String,
              let createdAt = json[Key.createdAt] as? TimeStamp,
              let updatedAt = json[Key.lastUpdatedAt] as? TimeStamp else { return nil }

        self.init(uid: docuID, name: name, createdAt: createdAt, lastUpdated: updatedAt)
        self.ownerID = json[Key.ownerID] as? String
        self.parentID = json[Key.parentID] as? String
        self.priority = (json[Key.priority] as? Int).flatMap { ReadPriority(rawValue: $0) }
        self.categoryIDs = json[Key.categoryIDs] as? [String] ?? []
        self.remindTime = json[Key.remindTime] as? TimeStamp
        self.collectionDescription = json[Key.collectionDescription] as? String
    }
    
    func asDocument() -> (String, JSON) {
        var json: JSON = [:]
        json[Key.name.rawValue] = self.name
        json[Key.createdAt.rawValue] = self.createdAt
        json[Key.lastUpdatedAt.rawValue] = self.lastUpdatedAt
        json[Key.ownerID.rawValue] = self.ownerID
        json[Key.parentID.rawValue] = self.parentID
        json[Key.priority.rawValue] = self.priority?.rawValue
        json[Key.categoryIDs.rawValue] = self.categoryIDs
        json[Key.remindTime.rawValue] = self.remindTime
        json[Key.collectionDescription.rawValue] = self.collectionDescription
        return (self.uid, json)
    }
}


// MARK: - ReadLink + Mapping

extension ReadLink: DocumentMappable {
    
    init?(docuID: String, json: JSON) {
        guard let link = json[Key.link] as? String,
              let createdAt = json[Key.createdAt] as? TimeStamp,
              let updatedAt = json[Key.lastUpdatedAt] as? TimeStamp else { return nil }
        self.init(uid: docuID, link: link, createAt: createdAt, lastUpdated: updatedAt)
        self.ownerID = json[Key.ownerID] as? String
        self.parentID = json[Key.parentID] as? String
        self.customName = json[Key.customName] as? String
        self.priority = (json[Key.priority] as? Int).flatMap { ReadPriority(rawValue: $0) }
        self.categoryIDs = json[Key.categoryIDs] as? [String] ?? []
        self.remindTime = json[Key.remindTime] as? TimeStamp
        self.isRed = json[Key.isRed] as? Bool ?? false
    }
    
    func asDocument() -> (String, JSON) {
        var json: JSON = [:]
        json[Key.link.rawValue] = self.link
        json[Key.createdAt.rawValue] = self.createdAt
        json[Key.lastUpdatedAt.rawValue] = self.lastUpdatedAt
        json[Key.ownerID.rawValue] = self.ownerID
        json[Key.parentID.rawValue] = self.parentID
        json[Key.customName.rawValue] = self.customName
        json[Key.priority.rawValue] = self.priority?.rawValue
        json[Key.categoryIDs.rawValue] = self.categoryIDs
        json[Key.remindTime.rawValue] = self.remindTime
        json[Key.isRed.rawValue] = self.isRed
        return (self.uid, json)
    }
}


struct CollectionCustomOrders: DocumentMappable {
    
    let collectionID: String
    let itemIDs: [String]
    
    init(collectionID: String, itemIDs: [String]) {
        self.collectionID = collectionID
        self.itemIDs = itemIDs
    }
    
    init?(docuID: String, json: JSON) {
        guard let itemIDs = json[Key.customOrders] as? [String] else { return nil }
        self.collectionID = docuID
        self.itemIDs = itemIDs
    }
    
    func asDocument() -> (String, JSON) {
        let json: JSON = [
            Key.customOrders.rawValue: self.itemIDs
        ]
        return (self.collectionID, json)
    }
}
