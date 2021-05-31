//
//  Auth+Mapping.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/05/09.
//

import Foundation


import Domain
import DataStore


// MARK: - Map ImageSource

enum ImageSourceMappingKey: String, JSONMappingKeys {
    case path
    case reference = "ref"
    case descirption = "desc"
    case emoji
}

extension ImageSource: JSONMappable {
    
    fileprivate typealias Key = ImageSourceMappingKey
    
    init?(json: JSON) {
        if let pathValue = json[Key.path] as? String {
            self = .path(pathValue)
            
        } else if let referenceJson = json[Key.reference] as? [String: Any],
                  let pathValue = referenceJson[Key.path] as? String {
            let description = referenceJson[Key.descirption] as? String
            self = .reference(pathValue, description: description)
            
        } else if let emoji = json[Key.emoji] as? String {
            self = .emoji(emoji)
            
        }  else {
            return nil
        }
    }
    
    func asJSON() -> JSON {
        switch self {
        case let .path(value):
            return [Key.path.rawValue: value]
            
        case let .reference(value, description):
            return [Key.reference.rawValue: [Key.path.rawValue: value, Key.descirption.rawValue: description]]
            
        case let .emoji(value):
            return [Key.emoji.rawValue: value]
        }
    }
}


// MARK: - map memebr

enum MemberMappingKey: String, JSONMappingKeys {
    case nicknanme = "nm"
    case icon
    case introduction = "intro"
}

extension Member: DocumentMappable {
    
    fileprivate typealias Key = MemberMappingKey
    
    init?(docuID: String, json: JSON) {
        self.init(uid: docuID)
        self.nickName = json[Key.nicknanme] as? String
        self.icon = (json[Key.icon] as? JSON).flatMap(ImageSource.init(json:))
        self.introduction = json[Key.introduction] as? String
    }
    
    func asDocument() -> (String, JSON) {
        var json = JSON()
        json[Key.nicknanme] = self.nickName
        json[Key.icon] = self.icon?.asJSON
        json[Key.introduction] = self.introduction
        return (self.uid, json)
    }
}

