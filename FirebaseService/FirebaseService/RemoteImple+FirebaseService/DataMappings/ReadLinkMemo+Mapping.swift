//
//  ReadLinkMemo+Mapping.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/11/01.
//

import Foundation

import Domain


enum ReadLinkMemoMappingKey: String, JSONMappingKeys {
    
    case content = "cnt"
}

private typealias Key = ReadLinkMemoMappingKey

extension ReadLinkMemo: DocumentMappable {
    
    init?(docuID: String, json: JSON) {
        self.init(itemID: docuID)
        self.content = json[Key.content] as? String
    }
    
    func asDocument() -> (String, JSON) {
        var json: JSON = [:]
        json[Key.content.rawValue] = self.content
        return (self.linkItemID, json)
    }
}
