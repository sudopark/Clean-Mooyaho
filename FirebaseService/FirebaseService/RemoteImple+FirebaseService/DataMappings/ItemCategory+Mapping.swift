//
//  ItemCategory+Mapping.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/11/01.
//

import Foundation

import Prelude
import Optics

import Domain
import Extensions


enum CategoryMappingKey: String, JSONMappingKeys {
    
    case name = "nm"
    case colorCode = "cc"
    case createdAt = "ct"
    case ownerID = "oid"
}

private typealias Key = CategoryMappingKey


// MARK: - ItemCategory + Mapping

extension ItemCategory: DocumentMappable {
    
    init?(docuID: String, json: JSON) {
        guard let name = json[Key.name] as? String,
              let code = json[Key.colorCode] as? String,
              let createdAt = json[Key.createdAt] as? TimeStamp,
              let ownerID = json[Key.ownerID] as? String else { return nil }
        self.init(uid: docuID, name: name, colorCode: code, createdAt: createdAt)
        self.ownerID = ownerID
    }
    
    func asDocument() -> (String, JSON) {
        var json: JSON = [:]
        json[Key.name] = self.name
        json[Key.colorCode] = self.colorCode
        json[Key.createdAt] = self.createdAt
        json[Key.ownerID] = self.ownerID
        return (self.uid, json)
    }
}
