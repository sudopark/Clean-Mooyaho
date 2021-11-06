//
//  ReadLinkMemo+Mapping.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/11/01.
//

import Foundation

import Domain


enum ReadLinkMemoMappingKey: String, JSONMappingKeys {
    
    case itemID = "item_id"
    case content = "cnt"
    case ownerID = "oid"
}

private typealias Key = ReadLinkMemoMappingKey

extension ReadLinkMemo: DocumentMappable {
    
    init?(docuID: String, json: JSON) {
        guard let itemID = json[Key.itemID] as? String else { return nil }
        self.init(itemID: itemID)
        self.content = json[Key.content] as? String
    }
    
    func asDocument() -> (String, JSON) {
        var json: JSON = [:]
        json[Key.itemID.rawValue] = self.linkItemID
        json[Key.content.rawValue] = self.content
        json[Key.ownerID.rawValue] = self.ownerID
        return (self.uuid, json)
    }
}
