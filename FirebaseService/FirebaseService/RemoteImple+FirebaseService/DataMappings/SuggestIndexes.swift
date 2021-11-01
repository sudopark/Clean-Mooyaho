//
//  SuggestIndexes.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/11/01.
//

import Foundation

import Domain

enum IndexType: String {
    case category
}


enum SugestIndexKeys: String, JSONMappingKeys {
    
    case itemID = "iid"
    case keyword = "kwd"
    case type = "idx_type"
    case ownerID = "oid"
    case lastUpdated = "lst_up_at"
    case additionalValue = "add_v"
}


private typealias Key = SugestIndexKeys


// MARK: - SuggestIndexMakeParams + Mapping

struct SuggestIndexMakeParams: JSONMappable {
    
    var itemID: String!
    var ownerID: String?
    var keyword: String!
    var type: IndexType!
    var lastUpdated: TimeStamp!
    var additionalValue: String?
    
    fileprivate init() {}
    
    init?(json: JSON) {
        guard let itemID = json[Key.itemID] as? String,
              let keyword = json[Key.keyword] as? String,
              let type = (json[Key.type] as? String).flatMap ({ IndexType(rawValue: $0) }),
              let lastUpdated = json[Key.lastUpdated] as? TimeStamp else { return }
        
        self.itemID = itemID
        self.keyword = keyword
        self.type = type
        self.lastUpdated = lastUpdated
        self.additionalValue = json[Key.additionalValue] as? String
        self.ownerID = json[Key.ownerID] as? String
    }
    
    func asJSON() -> JSON {
        var json: JSON = [:]
        json[Key.itemID.rawValue] = self.itemID
        json[Key.keyword.rawValue] = self.keyword
        json[Key.type.rawValue] = self.type.rawValue
        json[Key.ownerID.rawValue] = self.ownerID
        json[Key.lastUpdated.rawValue] = self.lastUpdated
        json[Key.additionalValue.rawValue] = self.additionalValue
        return json
    }
}


// MARK: - SuggestIndex + Mapping

struct SuggestIndex: DocumentMappable {
    
    let indexID: String
    let itemID: String
    let keyword: String
    let type: IndexType
    var ownerID: String?
    let lastUpdated: TimeStamp
    var additionalValue: String?
    
    init?(docuID: String, json: JSON) {
        guard let params = SuggestIndexMakeParams(json: json) else { return nil }
        self.indexID = docuID
        self.itemID = params.itemID
        self.keyword = params.keyword
        self.type = params.type
        self.ownerID = params.ownerID
        self.lastUpdated = params.lastUpdated
        self.additionalValue = params.additionalValue
    }
    
    func asDocument() -> (String, JSON) {
        var json: JSON = [:]
        json[Key.itemID.rawValue] = self.itemID
        json[Key.keyword.rawValue] = self.keyword
        json[Key.type.rawValue] = self.type.rawValue
        json[Key.ownerID.rawValue] = self.ownerID
        json[Key.lastUpdated.rawValue] = self.lastUpdated
        json[Key.additionalValue.rawValue] = self.additionalValue
        return (self.indexID, json)
    }
}


// MARK: - ItemCategory -> Index / Index -> SuggestCategory

extension ItemCategory {
    
    func asIndexMakeParams(_ ownerID: String) -> SuggestIndexMakeParams {
        var sender = SuggestIndexMakeParams()
        sender.itemID = self.uid
        sender.keyword = self.name
        sender.type = .category
        sender.ownerID = ownerID
        sender.lastUpdated = .now()
        sender.additionalValue = self.colorCode
        return sender
    }
}


extension SuggestIndex {
    
    func asSuggestCategory() -> SuggestCategory? {
        
        guard let code = self.additionalValue else { return nil }
        let category = ItemCategory(uid: self.itemID, name: self.keyword, colorCode: code)
        return .init(ownerID: self.ownerID, category: category, lastUpdated: self.lastUpdated)
    }
}
