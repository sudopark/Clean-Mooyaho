//
//  ItemCategory+Mapping.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/11/01.
//

import Foundation

import Domain


enum CategoryMappingKey: String, JSONMappingKeys {
    
    case name = "nm"
    case colorCode = "cc"
    case createdAt = "ct"
}

private typealias Key = CategoryMappingKey


// MARK: - ItemCategory + Mapping

extension ItemCategory: DocumentMappable {
    
    init?(docuID: String, json: JSON) {
        guard let name = json[Key.name] as? String,
              let code = json[Key.colorCode] as? String,
              let createdAt = json[Key.createdAt] as? TimeStamp else { return nil }
        self.init(uid: docuID, name: name, colorCode: code, createdAt: createdAt)
    }
    
    func asDocument() -> (String, JSON) {
        let json: JSON = [
            Key.name.rawValue: self.name,
            Key.colorCode.rawValue: self.colorCode,
            Key.createdAt.rawValue: self.createdAt
        ]
        return (self.uid, json)
    }
}
