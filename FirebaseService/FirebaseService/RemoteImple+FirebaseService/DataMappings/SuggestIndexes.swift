//
//  SuggestIndexes.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/11/01.
//

import Foundation

import Prelude
import Optics

import Domain

enum IndexType: String {
    case category = "cate"
    case link = "lnk"
    case collection = "clc"
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


// MARK: - ItemCategory -> SuggestIndex / SuggestIndex -> SuggestCategory

extension ItemCategory {
    
    func asIndexes(_ ownerID: String) -> SuggestIndex {
        return .init(indexID: self.uid, keyword: self.name, type: .category,
                     ownerID: ownerID, lastUpdated: .now(), additionalValue: self.colorCode)
    }
}


extension SuggestIndex {
    
    func asSuggestCategory() -> SuggestCategory? {
        
        guard let code = self.additionalValue else { return nil }
        let category = ItemCategory(uid: self.indexID, name: self.keyword,
                                    colorCode: code, createdAt: self.lastUpdated)
        return .init(ownerID: self.ownerID, category: category, lastUpdated: self.lastUpdated)
    }
}


// MARK: - Readitem -> SuggestIndex

extension ReadCollection {
    
    func asIndex() -> SuggestIndex {

        let additionValue = ReadItemIndexAdditionalValue()
            |> \.categoryIDs .~ self.categoryIDs
            |> \.description .~ self.collectionDescription
        
        return .init(indexID: self.uid, keyword: self.name, type: .collection,
                     ownerID: self.ownerID, lastUpdated: .now(),
                     additionalValue: additionValue.asEncodedString())
    }
}

extension ReadLink {
    
    func asIndexWithCustomTitle() -> SuggestIndex? {
        guard let name = self.customName else { return nil }
        return self.asIndex(with: name)
    }
    
    func asIndex(with name: String) -> SuggestIndex {
        let additionValue = ReadItemIndexAdditionalValue()
            |> \.categoryIDs .~ self.categoryIDs
        
        return .init(indexID: self.uid, keyword: name, type: .link,
                     ownerID: self.ownerID, lastUpdated: .now(),
                     additionalValue: additionValue.asEncodedString())
    }
}


// MARK: - SuggestIndex -> SuggestReadItemIndex

extension SuggestIndex {
    
    func asReadItemIndex() -> SearchReadItemIndex? {
        guard self.type != .category else { return nil }
        let value = ReadItemIndexAdditionalValue(additionValue: self.additionalValue)
        return .init(itemID: self.indexID,
                     isCollection: self.type == .collection,
                     displayName: self.keyword)
            |> \.categoryIDs .~ (value?.categoryIDs ?? [])
            |> \.description .~ value?.description
    }
}


struct ReadItemIndexAdditionalValue: Codable {
    
    var categoryIDs: [String]?
    var description: String?
    
    enum CodingKeys: String, CodingKey {
        case categoryIDs = "cates"
        case description = "desc"
    }
    
    init() {}
    
    init?(additionValue: String?) {
        guard let data = additionValue?.data(using: .utf8),
              let value = try? JSONDecoder().decode(ReadItemIndexAdditionalValue.self, from: data)
        else { return nil }
        self = value
    }
    
    func asEncodedString() -> String? {
        let data = try? JSONEncoder().encode(self)
        return data.flatMap { String(data: $0, encoding: .utf8) }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.categoryIDs = try? container.decode([String].self, forKey: .categoryIDs)
        self.description = try? container.decode(String.self, forKey: .description)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(self.categoryIDs, forKey: .categoryIDs)
        try? container.encode(self.description, forKey: .description)
    }
}
