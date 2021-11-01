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


enum SuggestIndexKeys: String, JSONMappingKeys {
    
    case keyword = "kwd"
    case type = "idx_type"
    case ownerID = "oid"
    case lastUpdated = "lst_up_at"
    case additionalValue = "add_v"
}


private typealias Key = SuggestIndexKeys


// MARK: - SuggestIndex + Mapping

struct SuggestIndex: DocumentMappable {
    
    let indexID: String
    let keyword: String
    let type: IndexType
    var ownerID: String?
    let lastUpdated: TimeStamp
    var additionalValue: String?
    
    init(indexID: String,
         keyword: String, type: IndexType,
         ownerID: String?, lastUpdated: TimeStamp, additionalValue: String?) {
        self.indexID = indexID
        self.keyword = keyword
        self.type = type
        self.ownerID = ownerID
        self.lastUpdated = lastUpdated
        self.additionalValue = additionalValue
    }
    
    init?(docuID: String, json: JSON) {
        guard let keyword = json[Key.keyword] as? String,
              let type = (json[Key.type] as? String).flatMap ({ IndexType(rawValue: $0) }),
              let lastUpdated = json[Key.lastUpdated] as? TimeStamp else { return nil }
        
        self.indexID = docuID
        self.keyword = keyword
        self.type = type
        self.ownerID = json[Key.ownerID] as? String
        self.lastUpdated = lastUpdated
        self.additionalValue = json[Key.additionalValue] as? String
    }
    
    func asDocument() -> (String, JSON) {
        var json: JSON = [:]
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
    
    func asIndexes(_ ownerID: String) -> SuggestIndex {
        return .init(indexID: self.uid, keyword: self.name, type: .category,
                     ownerID: ownerID, lastUpdated: .now(), additionalValue: self.colorCode)
    }
}


extension SuggestIndex {
    
    func asSuggestCategory() -> SuggestCategory? {
        
        guard let code = self.additionalValue else { return nil }
        let category = ItemCategory(uid: self.indexID, name: self.keyword, colorCode: code)
        return .init(ownerID: self.ownerID, category: category, lastUpdated: self.lastUpdated)
    }
}
